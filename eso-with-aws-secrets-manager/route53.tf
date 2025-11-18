resource "aws_acm_certificate" "cloudfront" {
  provider          = aws.us_east_1
  domain_name       = "${local.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cloudfront_validation" {
  provider = aws.us_east_1
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_validation : record.fqdn]
}

resource "aws_route53_record" "cloudfront" {
  name    = local.subdomain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
