output "eso_irsa_arn" {
  value = module.eso_irsa.arn
}

output "node_iam_role_name" {
  value = module.eks.node_iam_role_name
}

output "eso_irsa_arn_playground" {
  value = module.eso_irsa_playground.arn
}

output "node_iam_role_name_playground" {
  value = module.eks_playground.node_iam_role_name
}

output "website_endpoint" {
  value = "https://${local.subdomain_name}.${var.domain_name}"
}
