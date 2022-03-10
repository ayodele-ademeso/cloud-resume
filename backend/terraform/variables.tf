variable "aws-region" {
  type    = string
  default = "us-east-1"
}

variable "dynamo_db_table" {
  type    = string
  default = "visitor-count"
}

variable "bucket_name" {
  description = "S3 bucket to store static files"
  type        = string
  default     = "cloud-resume-spencer"
}

variable "acl_value" {
  description = "ACL to be set on bucket"
  type        = string
  default     = "public-read-write"
}