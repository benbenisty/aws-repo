# Provider configuration: Setting up AWS as our cloud provider
provider "aws" {
  region = "us-east-1"  # Specify the AWS region where resources will be created
}

# S3 Bucket Configuration: This bucket will store the files created by the Lambda function
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-demo-bucket"  # Ensure the bucket name is globally unique across AWS
  acl    = "private"  # Sets the bucket access level to private for security
}

# IAM Role for Lambda Execution
# Lambda needs permissions to interact with S3, so we create an IAM role with the necessary policies
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_execution_role"  # A custom name for the IAM role
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Action"    : "sts:AssumeRole",
      "Principal" : { "Service" : "lambda.amazonaws.com" },  # Lambda service is allowed to assume this role
      "Effect"    : "Allow"
    }]
  })
}

# Attach a Policy to Allow Full Access to S3
# This policy gives the Lambda function full access to interact with S3 buckets and objects
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  # AWS managed policy for S3 full access
}

# Lambda Function Configuration
resource "aws_lambda_function" "s3_lambda_function" {
  function_name    = "S3UploadLambda"  # Name of the Lambda function
  role             = aws_iam_role.lambda_role.arn  # IAM role with S3 access
  handler          = "lambda_function.lambda_handler"  # Specifies the entry point for the Lambda function (Python function name in the script)
  runtime          = "python3.8"  # Specifies the runtime environment for the Lambda function
  filename         = "${path.module}/lambda_function/lambda_function.zip"  # Points to the zipped Lambda function code
  source_code_hash = filebase64sha256("${path.module}/lambda_function/lambda_function.zip")  # Tracks changes to the code for redeployment

  # Environment Variables for Lambda
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.lambda_bucket.bucket  # Passes the S3 bucket name as an environment variable to the Lambda function
    }
  }
}

# Outputs: These provide useful information after Terraform completes, for verifying the setup
output "bucket_name" {
  value = aws_s3_bucket.lambda_bucket.bucket  # Outputs the bucket name, helpful for verification
}

output "l

