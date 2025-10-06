resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
name: ${local.eks_argocd_name}
nodeIamRoleArn: ${module.eks-argocd.node_iam_role_arn}
EOT
}

resource "gitsync_values_yaml" "elk" {
  branch  = "master"
  path    = "gasx/elk/values.yaml"
  content = <<EOT
name: ${local.eks_elk_name}
nodeIamRoleArn: ${module.eks-elk.node_iam_role_arn}
EOT
}

resource "gitsync_values_yaml" "internal-01" {
  branch  = "master"
  path    = "gasx/internal-01/values.yaml"
  content = <<EOT
name: ${local.eks_internal_01_name}
nodeIamRoleArn: ${module.eks-internal-01.node_iam_role_arn}
hello-world:
  enabled: true
  replicaCount: 2
EOT
}
