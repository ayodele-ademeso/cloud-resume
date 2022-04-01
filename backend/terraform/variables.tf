variable "aws-region" {
  type    = string
  default = "us-east-1"
}

variable "dynamo_db_table" {
  type    = string
  default = "visitor-counter"
}

variable "bucket_name" {
  description = "S3 bucket to store static files"
  type        = string
  default     = "www.ayodele.cloud"
}

variable "acl_value" {
  description = "ACL to be set on bucket"
  type        = string
  default     = "public-read"
}