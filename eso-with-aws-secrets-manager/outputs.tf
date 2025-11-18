output "eso_irsa_arn" {
  value = module.eso_irsa.arn
}

output "node_iam_role_name" {
  value = module.eks.node_iam_role_name
}

output "website_endpoint" {
  value = "https://${local.subdomain_name}.${var.domain_name}"
}

output "static_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}
