import snowflake.connector
import requests
from bs4 import BeautifulSoup
import json
import boto3
from loguru import logger
from os import path
import os
import io
import csv
from concurrent.futures import ThreadPoolExecutor
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from mage_ai.data_preparation.repo_manager import get_repo_path
from mage_ai.io.config import ConfigFileLoader

if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom

# Initialize environment variables
ENV_CODE = os.getenv('ENV_CODE', default=None)
PROJ_CODE = os.getenv('PROJ_CODE', default=None)

# Snowflake Configuration
SNOWFLAKE_USER = ENV_CODE + "_" + PROJ_CODE + "_DBT_USER"
SNOWFLAKE_PASSWORD = os.getenv('SNOWSQL_PWD', default=None)
SNOWFLAKE_ACCOUNT = os.getenv('SNOWSQL_ACCOUNT', default=None)
SNOWFLAKE_WAREHOUSE = ENV_CODE + "_" + PROJ_CODE + "_DBT_WH_XS"
SNOWFLAKE_DATABASE = ENV_CODE + "_" + PROJ_CODE + "_RAW_DB"
SNOWFLAKE_SCHEMA = 'CRICSHEET'

# Load configuration
config_path = path.join(get_repo_path(), 'io_config.yaml')
config_profile = 'default'
config_loader = ConfigFileLoader(config_path, config_profile)

# AWS Configuration
AWS_ACCESS_KEY_ID = config_loader['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = config_loader['AWS_SECRET_ACCESS_KEY']
AWS_REGION = config_loader['AWS_REGION']
BUCKET_NAME = os.getenv('BUCKET_NAME_DW_INPUT', default=None)

# Initialize requests session
requests_session = requests.Session()
retries = Retry(total=5, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
adapter = HTTPAdapter(pool_connections=100, pool_maxsize=100, max_retries=retries)
requests_session.mount('https://', adapter)

# Initialize boto3 S3 client
s3_client = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name=AWS_REGION
)

def to_snake_case(text):
    return text.lower().replace(" ", "_")

def write_to_s3_async(player_metrics):
    player_id = player_metrics['player_id']
    file_name = f"cricinfo/player_metrics/{player_id}.json"
    s3_client.put_object(
        Body=json.dumps(player_metrics),
        Bucket=BUCKET_NAME,
        Key=file_name
    )

def is_player_url_accessible(player_id):
    url = f"https://www.espncricinfo.com/ci/engine/player/{player_id}.html"
    try:
        response = requests_session.head(url, allow_redirects=True)
        return response.status_code == 200
    except requests.RequestException as e:
        logger.error(f"HEAD request to {url} failed with exception: {e}")
        return False

def fetch_player_stats(player_id, player_code, player_name):
    base_url = f"https://stats.espncricinfo.com/ci/engine/player/{player_id}.html?class="
    template_url = ";template=results;type="
    matches = ['1', '2', '3']
    types = ['batting', 'bowling', 'fielding']

    stats = {}
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    for match in matches:
        match_type = { '1': 'tests', '2': 'odis', '3': 't20s' }[match]
        for typ in types:
            url = f"{base_url}{match}{template_url}{typ}"
            try:
                response = requests_session.get(url, headers=headers)
                response.raise_for_status()

                soup = BeautifulSoup(response.content, 'html.parser')
                tables = soup.find_all('table', class_='engineTable')

                for table in tables:
                    caption = table.caption
                    if caption and "Career averages" in caption.get_text(strip=True):
                        break
                else:
                    raise IndexError(f"Couldn't find a suitable table for {typ} in {match_type}")

                column_headers = [th.get('title') for th in table.find('thead').find_all('th') if th.get('title')]
                rows = table.find_all('tr', class_='data1')
                
                columns = [col for col in rows[0].find_all('td') if 'overall' not in col.get_text(strip=True).lower()]
                data = {to_snake_case(column_headers[i]): col.get_text(strip=True) for i, col in enumerate(columns) if i < len(column_headers) and column_headers[i]}

                if match_type not in stats:
                    stats[match_type] = {}
                stats[match_type][typ] = data

            except IndexError:
                pass
            except Exception as e:
                logger.error(f"[Player ID: {player_id}] Error fetching stats with URL {url}: {e}")

    if stats:
        stats.update({
            'player_id': player_id,
            'player_code': player_code,
            'player_name': player_name
        })
        return stats
    return None

def empty_s3_directory(bucket_name, prefix):
    paginator = s3_client.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=bucket_name, Prefix=prefix)

    for page in pages:
        if 'Contents' in page:
            delete_params = {'Objects': [{'Key': obj['Key']} for obj in page['Contents']]}
            s3_client.delete_objects(Bucket=bucket_name, Delete=delete_params)

audit_data = []

def add_audit_entry(player_id, player_code, player_name, success_status):
    audit_entry = {
        'player_id': player_id,
        'player_code': player_code, 
        'player_name': player_name,
        'scrape_status': success_status
    }
    audit_data.append(audit_entry)

def write_audit_data_to_s3():
    audit_file = "audit/cricinfo/player_metrics.csv"

    try:
        csv_data = io.StringIO()
        writer = csv.writer(csv_data)
        if not s3_client.list_objects(Bucket=BUCKET_NAME, Prefix=audit_file):
            writer.writerow(['player_id', 'player_code', 'player_name', 'scrape_status'])
        for player_audit in audit_data:
            writer.writerow([
                player_audit['player_id'],
                player_audit['player_code'],
                player_audit['player_name'],
                'Success' if player_audit['scrape_status'] else 'Failed'
            ])

        s3_client.put_object(
            Body=csv_data.getvalue(),
            Bucket=BUCKET_NAME,
            Key=audit_file
        )
        logger.info(f"Audit data saved to S3 bucket {BUCKET_NAME} at key {audit_file}")
    except Exception as e:
        logger.error(f"Error while writing the audit CSV file and uploading to S3: {e}")

def process_player_data(future, player):
    player_metrics = future.result()
    if player_metrics:
        write_to_s3_async(player_metrics)
        add_audit_entry(player_metrics['player_id'], player_metrics['player_code'], player_metrics['player_name'], True)
    else:
        add_audit_entry(player[1], player[0], player[2], False)

@custom
def fetch_and_save_player_metrics_to_s3(*args, **kwargs):
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
        logger.info("Fetching player records from Snowflake table.")
        cursor.execute("select DISTINCT identifier, namekey_cricinfo_2 as namekey_cricinfo, name from all_player_data")
        players = cursor.fetchall()
        logger.info(f"Successfully fetched {len(players)} player records.")
    except Exception as e:
        logger.error(f"Error while fetching player records: {e}")
        return []

    players_total_count = len(players)

    if players_total_count > 0:
        logger.info("Emptying the S3 directory before writing new files.")
        empty_s3_directory(BUCKET_NAME, 'cricinfo/player_metrics/')

    with ThreadPoolExecutor(max_workers=50) as executor:
        for player in players:
            player_code, player_id, player_name = player
            if not is_player_url_accessible(player_id):
                logger.error(f"Player stats URL not accessible for Player ID: {player_id}")
                add_audit_entry(player_id, player_code, player_name, False)
            else:
                future = executor.submit(fetch_player_stats, player_id, player_code, player_name)
                future.add_done_callback(lambda fut: process_player_data(fut, player))

    # Ensure all futures have completed before proceeding
    executor.shutdown(wait=True)
    write_audit_data_to_s3()
