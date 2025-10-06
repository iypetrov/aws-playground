resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
nodeIAMRoleARN: ${module.eks.node_iam_role_arn}
EOT
}
