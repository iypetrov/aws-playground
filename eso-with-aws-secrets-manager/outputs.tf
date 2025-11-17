output "eso_irsa_arn" {
    value = module.eso_irsa.arn
}

output "node_iam_role_name" {
    value = module.eks.node_iam_role_name
}
