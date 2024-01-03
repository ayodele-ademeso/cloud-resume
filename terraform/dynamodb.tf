data "aws_caller_identity" "current" {}

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