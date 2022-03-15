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
  name         = "visitor-count"
  hash_key     = "visitorcount"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "visitorcount"
    type = "S"
  }

}

#Create Lambda role to access DynamoDB

resource "aws_iam_role" "role_for_dynamodb" {
  name               = "myrole"
  assume_role_policy = file("../assume_role_policy.json")

}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.role_for_dynamodb.id
  policy = file("../policy.json")
}

resource "aws_lambda_function" "lambda" {
  filename      = "../lambda_function.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.role_for_dynamodb.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../lambda_function.zip")

  runtime = "python3.8"

  environment {
    variables = {
      ddbname = "visitor-count"
    }
  }
}

#Create API Gateway

resource "aws_api_gateway_rest_api" "api" {
  name        = "CounterAPI"
  description = "API Gateway to retrieve counter from DynamoDB"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "count"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}