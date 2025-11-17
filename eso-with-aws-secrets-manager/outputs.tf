output "eso_irsa_arn" {
  value = module.eso_irsa.arn
}

output "node_iam_role_name" {
  value = module.eks.node_iam_role_name
}

output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${local.aws_region}.amazonaws.com/${local.env}"
}
