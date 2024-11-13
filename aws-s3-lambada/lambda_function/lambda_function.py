import boto3
import datetime

def lambda_handler(event, context):
    # Initialize S3 client
    s3_client = boto3.client("s3")
    bucket_name = os.environ["BUCKET_NAME"]
    
    # Create text content
    text_content = "This is a test file created by Lambda on " + str(datetime.datetime.now())
    
    # Define the filename and upload it to S3
    file_name = "lambda_created_file.txt"
    s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=text_content)
    
    return f"File {file_name} successfully created and uploaded to S3 bucket {bucket_name}"

