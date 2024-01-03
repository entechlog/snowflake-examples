import boto3
import csv
import io
import json
import os
import requests
import snowflake.connector
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor
from loguru import logger
from os import path
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from mage_ai.data_preparation.repo_manager import get_repo_path
from mage_ai.io.config import ConfigFileLoader

if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom

ENV_CODE = os.getenv('ENV_CODE', default=None)
PROJ_CODE = os.getenv('PROJ_CODE', default=None)

SNOWFLAKE_USER = ENV_CODE + "_" + PROJ_CODE + "_DBT_USER"
SNOWFLAKE_PASSWORD = os.getenv('SNOWSQL_PWD', default=None)
SNOWFLAKE_ACCOUNT = os.getenv('SNOWSQL_ACCOUNT', default=None)
SNOWFLAKE_WAREHOUSE = ENV_CODE + "_" + PROJ_CODE + "_DBT_WH_XS"
SNOWFLAKE_DATABASE = ENV_CODE + "_" + PROJ_CODE + "_RAW_DB"
SNOWFLAKE_SCHEMA = 'CRICSHEET'

config_path = path.join(get_repo_path(), 'io_config.yaml')
config_profile = 'default'
config_loader = ConfigFileLoader(config_path, config_profile)

AWS_ACCESS_KEY_ID = config_loader['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = config_loader['AWS_SECRET_ACCESS_KEY']
AWS_REGION = config_loader['AWS_REGION']
BUCKET_NAME = os.getenv('BUCKET_NAME_DW_INPUT', default=None)

requests_session = requests.Session()
retries = Retry(total=5, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
adapter = HTTPAdapter(pool_connections=100, pool_maxsize=100, max_retries=retries)
requests_session.mount('https://', adapter)

s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION
)

def empty_s3_directory(bucket_name, prefix):
    paginator = s3_client.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=bucket_name, Prefix=prefix)

    delete_us = []
    for page in pages:
        if 'Contents' in page:
            for obj in page['Contents']:
                delete_us.append({'Key': obj['Key']})

            if len(delete_us) > 0:
                delete_params = {'Objects': delete_us}
                s3_client.delete_objects(Bucket=bucket_name, Delete=delete_params)
                delete_us.clear()

def get_player_details_from_cricinfo(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    try:
        response = requests_session.get(url, headers=headers)
        response.raise_for_status()

        soup = BeautifulSoup(response.content, 'html.parser')
        batting_style_elem = soup.find("p", text="Batting Style")
        batting_style = batting_style_elem.find_next_sibling("span").text.strip() if batting_style_elem else None

        bowling_style_elem = soup.find("p", text="Bowling Style")
        bowling_style = bowling_style_elem.find_next_sibling("span").text.strip() if bowling_style_elem else None

        born_elem = soup.find("p", text="Born")
        born = born_elem.find_next_sibling("span").text.strip() if born_elem else None

        playing_role_elem = soup.find("p", text="Playing Role")
        playing_role = playing_role_elem.find_next_sibling("span").text.strip() if playing_role_elem else None

        teams = [team.span.text.strip() for team in soup.find_all("a", class_="ds-flex ds-items-center ds-space-x-4")]

        return {
            'batting_style': batting_style,
            'bowling_style': bowling_style,
            'born': born,
            'playing_role': playing_role,
            'teams': teams
        }
    
    except Exception as err:
        logger.error(f"Error while fetching player details from Cricinfo: {err}")
        return None

@custom
def fetch_and_save_player_details_to_s3(*args, **kwargs):
    conn = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        warehouse=SNOWFLAKE_WAREHOUSE,
        database=SNOWFLAKE_DATABASE,
        schema=SNOWFLAKE_SCHEMA
    )
    cursor = conn.cursor()

    try:
        empty_s3_directory(BUCKET_NAME, 'cricinfo/player_details/')
        logger.info("Successfully emptied the directory in S3 bucket.")
    except Exception as e:
        logger.error(f"Error while emptying the directory in S3 bucket: {e}")
        return f"Error while emptying the directory in S3 bucket: {e}"

    try:
        logger.info("Fetching player records from Snowflake table.")
        cursor.execute("select DISTINCT identifier, namekey_cricinfo_2 as namekey_cricinfo, name from all_player_data")
        players = cursor.fetchall()
        logger.info(f"Successfully fetched {len(players)} player records.")
    except Exception as e:
        logger.error(f"Error while fetching player records: {e}")
        return []

    additional_details = []

    with ThreadPoolExecutor(max_workers=50) as executor:
        future_to_url = {executor.submit(get_player_details_from_cricinfo, f"https://www.espncricinfo.com/player/{'-'.join(player[2].lower().split())}-{player[1]}"): player for player in players}
        for future in future_to_url:
            player_code, player_id, player_name = future_to_url[future]
            try:
                player_data = future.result()
                if player_data:
                    player_data.update({'player_id': player_id, 'player_code': player_code, 'player_name': player_name})
                    player_file_name = f"cricinfo/player_details/{player_id}.json"
                    s3_key = player_file_name
                    json_data = json.dumps(player_data)

                    try:
                        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_key, Body=json_data, ContentType='application/json')
                    except Exception as e:
                        logger.error(f"Error while saving player data to S3: {e}")

                    additional_details.append(player_data)
            except Exception as exc:
                logger.error(f"Error occurred during fetching data for player {player_name}: {exc}")

    cursor.close()
    conn.close()

    if not additional_details:
        logger.error("No data fetched. Skipping the saving to S3.")
        return "No data fetched."
    
    audit_file = "audit/cricinfo/player_details.csv"
    try:
        csv_data = io.StringIO()
        writer = csv.writer(csv_data)
        if not s3_client.list_objects(Bucket=BUCKET_NAME, Prefix=audit_file):
            writer.writerow(['player_id', 'player_code', 'player_name', 'webscrape_status'])
        for player_data in additional_details:
            webscrape_status = "Success" if 'player_id' in player_data else "Failed"
            writer.writerow([
                player_data.get('player_id', ''),
                player_data.get('player_code', ''),
                player_data.get('player_name', ''),
                webscrape_status
            ])

        s3_client.put_object(
            Body=csv_data.getvalue(),
            Bucket=BUCKET_NAME,
            Key=audit_file
        )
        logger.info(f"Audit data saved to S3 bucket {BUCKET_NAME} at key {audit_file}")
    except Exception as e:
        logger.error(f"Error while writing the audit CSV file and uploading to S3: {e}")

    logger.info("Player details and audit data saved to S3.")
    return f"Player details and audit data saved to S3 bucket {BUCKET_NAME}."
