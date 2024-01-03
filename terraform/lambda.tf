data "aws_iam_policy_document" "iam_for_lambda_policy" {
  statement {
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    effect = "Allow"
    resources = concat(
      [format("arn:aws:dynamodb:%s:%s:table/%s", var.aws-region, data.aws_caller_identity.current.account_id, var.dynamo_db_table)]
    )
  }
  statement {
    actions = [
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

#Create Lambda role to access DynamoDB
resource "aws_iam_role" "role_for_dynamodb" {
  name = "cloud_resume_lambda_role"
  #   assume_role_policy = file("../assume_role_policy.json")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["lambda.amazonaws.com"]
        }
    }]
  })

  inline_policy {
    name   = "lambda_policy"
    policy = data.aws_iam_policy_document.iam_for_lambda_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.role_for_dynamodb.name
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/count"
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "../backend/lambda_function.py"
  output_path = "../backend/lambda_function.zip"
}

# Create Lambda function
resource "aws_lambda_function" "lambda" {
  filename         = "../backend/lambda_function.zip"
  function_name    = "ayodele_lambda_function" #var.lambda_function_name
  role             = aws_iam_role.role_for_dynamodb.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("../backend/lambda_function.zip")
  runtime          = "python3.8" #var.lambda_runtime
  publish          = true

  environment {
    variables = {
      DB_NAME = var.dynamo_db_table
    }
  }
}