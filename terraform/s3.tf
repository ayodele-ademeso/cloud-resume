#Create s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketacl" {
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.acl_value
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.website.json
}

resource "aws_s3_object" "web_app" {
  bucket       = aws_s3_bucket.bucket.id
  key          = "index.html"
  source       = "${path.root}/template/index.html"
  content_type = "text/html"
}