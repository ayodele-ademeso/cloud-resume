data "aws_route53_zone" "main" {
  name = var.website_domain
}

data "aws_acm_certificate" "prod_ssl" {
  domain   = var.website_domain
  statuses = ["ISSUED"]
  # provider    = aws.virginia
  most_recent = true
}

data "aws_iam_policy_document" "website" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.website.iam_arn]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.website_domain}/*"
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "website cloudfront access identity"
}

resource "aws_cloudfront_distribution" "website" {
  aliases             = [var.website_domain, "www.${var.website_domain}"]
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = false
  tags                = {}

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 1800
    max_ttl                = 3600
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = aws_s3_bucket.bucket.id
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.prod_ssl.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.website_domain
  type    = "A"

  alias {
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    name                   = aws_cloudfront_distribution.website.domain_name
    evaluate_target_health = false
  }
}