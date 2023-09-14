import boto3
import requests
from loguru import logger
from mage_ai.data_preparation.repo_manager import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from os import path
import datetime
import threading
import hashlib
import tempfile
import os

if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom

config_path = path.join(get_repo_path(), 'io_config.yaml')
config_profile = 'default'
config_loader = ConfigFileLoader(config_path, config_profile)

# Set AWS credentials
AWS_ACCESS_KEY_ID = config_loader['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = config_loader['AWS_SECRET_ACCESS_KEY']
AWS_REGION = config_loader['AWS_REGION']

BUCKET_NAME = os.getenv('BUCKET_NAME_DW_INPUT', default=None)
#url = os.getenv('URL_CRICSHEET_PEOPLE_DATA', default=None)
url = "https://cricsheet.org/register/people.csv"

class S3ProgressPercentage:
    def __init__(self, logger, total_size):
        self._total_size = total_size
        self._seen_so_far = 0
        self._lock = threading.Lock()
        self._last_logged_time = datetime.datetime.now()
        self._logger = logger

    def __call__(self, bytes_amount):
        with self._lock:
            self._seen_so_far += bytes_amount
            percentage = (self._seen_so_far / self._total_size) * 100
            current_time = datetime.datetime.now()
            if (current_time - self._last_logged_time).total_seconds() >= 10:
                self._logger.info("Upload progress: {:.2f}%".format(percentage))
                self._last_logged_time = current_time

def calculate_md5(fileobj):
    hasher = hashlib.md5()
    for chunk in iter(lambda: fileobj.read(4096), b""):
        hasher.update(chunk)
    return hasher.hexdigest()

def get_s3_client():
    """ Create and return an S3 client using the provided AWS credentials. """
    return boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_SECRET_ACCESS_KEY, region_name=AWS_REGION)

s3_client = get_s3_client()

@custom
def download_and_upload_to_s3(*args, **kwargs):
    """ Download the CSV from the given API endpoint and upload it to S3. """
    
    logger.info("Initiated API call to {} for data retrieval.", url)
    response = requests.get(url, stream=True)

    if response.status_code == 200:
        with tempfile.NamedTemporaryFile() as temp_file:
            for chunk in response.iter_content(chunk_size=8192):
                temp_file.write(chunk)
            
            temp_file.seek(0)
            md5_checksum = calculate_md5(temp_file)
            
            latest_key = 'cricsheet/all_player_data/people.csv'
            
            try:
                latest_file = s3_client.head_object(Bucket=BUCKET_NAME, Key=latest_key)
                latest_md5 = latest_file['ETag'].strip('"')  # ETag contains the MD5 value
            except s3_client.exceptions.ClientError:
                latest_md5 = None
                logger.warning(f"Couldn't fetch the MD5 checksum from the 'latest' directory in S3. Assuming it doesn't exist.")
            
            if md5_checksum != latest_md5:
                size = int(response.headers.get('Content-Length', 0))
                
                now = datetime.datetime.utcnow()
                s3_key = 'archive/' + now.strftime('%Y%m%d/') + f"people_{now.strftime('%Y%m%d_%H%M%S%f')}.csv"
                progress = S3ProgressPercentage(logger, size)

                logger.info("API call to {} was successful. Downloaded CSV file of size: {} bytes.", url, size)
                logger.info("Starting upload of data to S3 bucket {} at key {}.", BUCKET_NAME, s3_key)
                
                # Upload file to archive
                temp_file.seek(0)
                s3_client.upload_fileobj(temp_file, BUCKET_NAME, s3_key, Callback=progress)

                # Log before updating the latest file
                logger.info("Updating 'latest' directory with the recent upload.")
                
                # Update latest file
                s3_client.copy_object(Bucket=BUCKET_NAME, CopySource={'Bucket': BUCKET_NAME, 'Key': s3_key}, Key=latest_key)

                logger.info("Upload of data to S3 bucket {} completed successfully.", BUCKET_NAME)
            else:
                logger.info(f"File already exists in S3 with the same MD5. No upload needed.")
            
    else:
        logger.error("Failed to fetch data from {}. HTTP Status: {}", url, response.status_code)

    return None