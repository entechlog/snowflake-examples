import boto3
import os
import logging
import logging.config
from urllib.parse import unquote_plus
from datetime import datetime

###############################################################################
# This creates multiple response folder if the same file was copied over again
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

            response_to_return = {
                "objectKey": s3_object_name, "response": response}

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

    # Generate output file name
    output_s3_object_name = generate_output_name(s3_object_name, 'text')
    # Detect TEXT
    response = client.start_document_text_detection(
        DocumentLocation={
            'S3Object': {
                'Bucket': s3_bucket_name,
                'Name': s3_object_name
            }},
        OutputConfig={
            'S3Bucket': s3_bucket_name,
            'S3Prefix': output_s3_object_name
        })

    job_id = response["JobId"]
    logger.info('Started job with id ~ {}'.format(job_id))

    # Logic to read a LINE from the document
    # Uncomment for debugging only to avoid printing critical data in logs

    # for result_page in response:
    #     for item in result_page["Blocks"]:
    #         if item["BlockType"] == "LINE":
    #             print("Line item from pdf       :", item["Text"])

    return response


def generate_output_name(s3_object_name, type):

    valid_file_formats = [".PDF", ".TIFF", ".JPG",
                          ".PNG", ".pdf", ".tiff", ".jpg", ".png"]

    s3_object_name = s3_object_name.split('/')[-1]

    for valid_file_format in valid_file_formats:
        s3_object_name = s3_object_name.replace(valid_file_format, "")

    output_dir_prefix = 'textract/response/' + \
        datetime.today().strftime('%Y-%m-%d') + '/' + type + '/' + \
        s3_object_name

    return output_dir_prefix
