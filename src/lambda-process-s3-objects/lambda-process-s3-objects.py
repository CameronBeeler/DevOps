import boto3
import logging

# Initialize logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Extract the bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    ingested_key = event['Records'][0]['s3']['object']['key']

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