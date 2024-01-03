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
    actions   = ["logs:DescribeLogStreams"]
    resources = ["*"]
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

# resource "aws_iam_role_policy" "lambda_policy" {
#   name   = "lambda_policy"
#   role   = aws_iam_role.role_for_dynamodb.id
#   policy = file("../policy.json")
# }

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