resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
nodeIamRoleArn: ${module.eks-argocd.node_iam_role_arn}
EOT
}
