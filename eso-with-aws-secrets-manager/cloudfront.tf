resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for S3 bucket"
}

resource "aws_cloudfront_distribution" "distribution" {
  depends_on = [
    aws_acm_certificate_validation.cloudfront
  ]

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["${local.subdomain_name}.${var.domain_name}"]

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = "${aws_api_gateway_rest_api.api.id}.execute-api.${local.aws_region}.amazonaws.com"
    origin_id   = "api-origin"

    origin_path = "/${aws_api_gateway_stage.api_stage.stage_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    target_origin_id = "s3-origin"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  default_cache_behavior {
    target_origin_id = "api-origin"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
