resource "aws_dynamodb_table" "dynamodb" {
    name = "$var.dynamo_db_table"
    hash_key = "id"
    billing_mode = "PAY_PER_REQUEST"

    attribute {
      name = "id"
      type = "S"
    }
  
}

resource "aws_dynamodb_table_item" "tableitem" {
    table_name = aws_dynamodb_table.dynamodb.id
    hash_key = aws_dynamodb_table.dynamodb.hash_key

    item = <<ITEM
{
    "id": {"N": "visitorcount"}
}
ITEM
}