variable "aws-region" {
  description = "AWS region to create resources"
  type        = string
  default = "us-east-1"
}

variable "dynamo_db_table" {
  description = "Name of the DynamoDB Table"
  type        = string
  default     = "visitor-count"
}

variable "bucket_name" {
  description = "S3 bucket to store static files"
  type        = string
  default     = "ayodele.cloud"
}

variable "acl_value" {
  description = "ACL to be set on bucket"
  type        = string
  default     = "private"
}

variable "website_domain" {
  description = "Name of the website. should be the same as the bucket name"
  type        = string
  default     = "ayodele.cloud"
}

variable "lambda_function_name" {
  description = "Name of the lambda function to create"
  type        = string
  default     = "ayodele_lambda_function"
}