import boto3
import sys
import json
import logging
from util.logger import BasicLogger
from util.s3_util import write_s3

# Initialize logger
global logger
# this will always log at the debug level
logger = BasicLogger(log_level=int(20)).get_logger()

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Extract the bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    ingested_key = event['Records'][0]['s3']['object']['key']
    
    # Log the event information
    logger.info(f"Received event: {event}")

    # Log the trigger event
    logger.info(f"Ingested object: {ingested_key} in bucket: {bucket_name}")

    # Define the destination key
    processed_key = ingested_key.replace('ingestion/', 'processed/')

    # Copy the object to the 'processed' key
    copy_source = {'Bucket': bucket_name, 'Key': ingested_key}
    s3_client.copy_object(CopySource=copy_source, Bucket=bucket_name, Key=processed_key)

    # Delete the original object from 'ingestion'
    s3_client.delete_object(Bucket=bucket_name, Key=ingested_key)

    # Log the move event
    logger.info(f"Moved object to: {processed_key} in bucket: {bucket_name}")

    return {
        'statusCode': 200,
        'body': f"Object {ingested_key} moved to {processed_key}."
    }
    

#    ========================================

def run():
    """
    from awsglue.utils import getResolvedOptions

    Runner function for all the functionalities in the script
    This is a manually executed glue job to validate connectivity between systems by created a sample data file in the
    destination S3 bucket
    All cross account permissions are stored in this IAM policy: resource_full_access_cns_bucket via Terraform
    TO RUN: update the s3_file_path_cross_account job param to the desired location
    """

""" -> tweak this code to work for the lambda function.  
    try:
        args = getResolvedOptions(
            sys.argv,
            ["s3_file_path_cross_account"],
        )

        s3_path_cross_account = args["s3_file_path_cross_account"]

        if not s3_path_cross_account:
            raise ValueError("Missing job params, s3_path_cross_account is required")

        sample_json = json.dumps(
            {"test": "Sample JSON sent from ODS for Connectivity Testing"}
        )

        # write cross account
        write_s3(
            s3_path_cross_account,
            "ODS_Test_Connection_File.csv",
            sample_json,
        )

    except Exception as e:
        logger.exception(e)
        raise e


if __name__ == "__main__":
    run()
"""