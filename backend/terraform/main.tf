terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "www.ayodele.cloud"
    key    = "backend/terraform.tfstate"
    region = "us-east-1"
  }
}



provider "aws" {
  region = "us-east-1"
}

# #Call s3 module
# module "s3" {
#   source = "./modules/"
# }

#Create s3 bucket
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
  function_name = "lambda_function_2"
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
  depends_on = [
    aws_lambda_function.lambda
  ]
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "prod_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "count"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "GET"
  authorization = "NONE"
}

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda.arn
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
# }

resource "aws_api_gateway_integration" "lambda_integration" {
  # depends_on = [
  #   aws_lambda_permission.apigw
  # ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.get.resource_id
  http_method = aws_api_gateway_method.get.http_method

  integration_http_method = "POST" # https://github.com/hashicorp/terraform/issues/9271 Lambda requires POST as the integration type
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = ""
  }
}


resource "aws_api_gateway_model" "model" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "DynamoDBOutput"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "DynamoDBOutputModel",
  "type": "object",
  "properties": {
    "Status-code": {
      "type": "integer"
    },
    "body": {
      "type": "object",
      "properties": {
        "count": {
          "type": "integer"
        }
      }
    }
  }
}
EOF
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
  response_models = {
    "application/json" = "DynamoDBOutput"
  }
}


resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path( '$' ))

$inputRoot.body
  EOF
  }
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_method.get]

  rest_api_id = aws_api_gateway_rest_api.api.id
}