import boto3
import botocore
import time
import json
import os
from collections import defaultdict
import logging
import logging.config
from urllib.parse import unquote_plus
from datetime import datetime
from trp import Document

###############################################################################
# This creates single response file even if the same file gets uploaded mutiple times
# One issue is long lambda runtime
###############################################################################

# Logging
logging.config.fileConfig(fname='log.conf')
logger = logging.getLogger(__name__)

# Initialize s3 connection
environment_code = os.environ.get('ENVIRONMENT_CODE', 'temp')
logger.info('Environment Code ~ {}'.format(environment_code))

# Initialize boto client for s3
if environment_code in ('local'):
    s3 = boto3.resource(
        's3', endpoint_url='http://host.docker.internal:4566', use_ssl=False)
else:
    s3 = boto3.resource('s3')


def lambda_handler(event, context):
    """
    Process incoming events
    """

    # Log the function name
    logger.info('Function Name ~ {}'.format(context.function_name))

    # 200 is the HTTP status code for "ok".
    status_code = 200

    # Initialize response
    response_to_return = {}

    # Loops through every file uploaded
    for record in event['Records']:

        # Log input payload
        logger.info('Input payload ~ {}'.format(record))

        # Get s3 details from the event trigger
        s3_bucket_region = record['awsRegion']
        s3_bucket_name = record['s3']['bucket']['name']
        s3_object_name = unquote_plus(record['s3']['object']['key'])

        # Log parsed input variables
        logger.info('s3_bucket_region ~ {}'.format(s3_bucket_region))
        logger.info('s3_bucket_name ~ {}'.format(s3_bucket_name))
        logger.info('s3_object_name ~ {}'.format(s3_object_name))

        # Initialize boto client for textract
        client = boto3.client('textract', region_name=s3_bucket_region)

        try:
            # Detect TEXT
            response = None
            response = perform_detect_document_text(
                client, s3_bucket_name, s3_object_name)

            write_response_to_s3(
                s3_bucket_name, s3_object_name, response, type='text')

            response_to_return = {
                "objectKey": s3_object_name, "status": "SUCCESS"}

        except Exception as err:
            logger.warn('Input error ~ {}'.format(err))
            # 400 implies some type of error.
            status_code = 400
            # Tell caller what this function could not handle.
            response_to_return = record

    # Return the return value and HTTP status code.
    return {
        'statusCode': status_code,
        'body': response_to_return
    }


def perform_detect_document_text(client, s3_bucket_name, s3_object_name):

    # Detect TEXT
    response = client.start_document_text_detection(
        DocumentLocation={
            'S3Object': {
                'Bucket': s3_bucket_name,
                'Name': s3_object_name
            }})

    job_id = response["JobId"]
    logger.info('Started job with id ~ {}'.format(job_id))

    if is_job_complete(client, job_id):
        response = get_job_results(client, job_id)

    # Logic to read a LINE from the document
    # Uncomment for debugging only to avoid printing critical data in logs

    # for result_page in response:
    #     for item in result_page["Blocks"]:
    #         if item["BlockType"] == "LINE":
    #             print("Line item from pdf       :", item["Text"])

    return response


def is_job_complete(client, job_id):
    time.sleep(5)
    response = client.get_document_text_detection(JobId=job_id)
    status = response["JobStatus"]
    logger.info('Textract job status ~ {}'.format(status))

    while (status == "IN_PROGRESS"):
        time.sleep(5)
        response = client.get_document_text_detection(JobId=job_id)
        status = response["JobStatus"]
        logger.info('Textract job status ~ {}'.format(status))

    return status


def get_job_results(client, job_id):
    pages = []
    time.sleep(5)
    response = client.get_document_text_detection(JobId=job_id)
    pages.append(response)
    logger.info('Resultset page received ~ {}'.format(len(pages)))
    next_token = None
    if 'NextToken' in response:
        next_token = response['NextToken']

    while next_token:
        time.sleep(5)
        response = client.\
            get_document_text_detection(JobId=job_id, NextToken=next_token)
        pages.append(response)
        logger.info('Resultset page received ~ {}'.format(len(pages)))
        next_token = None
        if 'NextToken' in response:
            next_token = response['NextToken']

    return pages


def write_response_to_s3(s3_bucket_name, s3_object_name, data, type):

    output_dir_prefix = 'textract/response/' + \
        datetime.today().strftime('%Y-%m-%d') + '/'

    if type == "text":
        output_s3_object_name = output_dir_prefix + type + '/' + \
            s3_object_name.replace('.pdf', '_detect_text_response.json')
    elif type == "doc":
        output_s3_object_name = output_dir_prefix + type + '/' + \
            s3_object_name.replace('.pdf', '_detect_doc_response.json')

    # Write back to S3 with the new file name
    try:
        s3.Bucket(s3_bucket_name).put_object(Key=output_s3_object_name, Body=(
            bytes(json.dumps(data).encode('UTF-8'))))
        logger.info('Target S3 Record Key ~ {}'.format(output_s3_object_name))
    except botocore.exceptions.ClientError as err:
        logging.error('S3 write to bucket {} with for key {} failed. {} '.format(
            s3_bucket_name, output_s3_object_name, err))

    return None
