#Create s3 module
resource "aws_s3_bucket" "bucket"{
    bucket = "$var.bucket-name"
}

resource "aws_s3_bucket_acl" "bucketacl" {
    bucket = aws_s3_bucket.bucket.id
    acl = "$var.acl_value"
}

resource "aws_s3_bucket_website_configuration" "config" {
    bucket = aws_s3_bucket.bucket.id

    index_document {
        suffix = "index.html"
    }
}

# resource "aws_s3_bucket_versioning" "versioning" {
# #     bucket = aws_s3_bucket.bucket.id
# #     versioning_configuration {
# #         status = "Enabled"
# #     }
# # }