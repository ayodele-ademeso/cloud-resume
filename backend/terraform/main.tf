terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# #Call s3 module
# module "s3" {
#   source = "./modules/"
# }

#Create s3 module
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "bucketacl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl_value
}

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

#Create DynamoDB table
resource "aws_dynamodb_table" "dynamodb" {
  name         = var.dynamo_db_table
  hash_key     = "visitorcount"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "visitorcount"
    type = "S"
  }

}

#Create Lambda function

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename      = "../lambda_function.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../lambda_function.zip")

  runtime = "python3.8"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

#Call API module