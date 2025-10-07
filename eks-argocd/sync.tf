resource "gitsync_values_yaml" "argocd" {
  branch  = "master"
  path    = "gasx/argocd/values.yaml"
  content = <<EOT
name: ${local.eks_argocd_name}
nodeIamRoleName: ${module.eks-argocd.node_iam_role_name}
EOT
}

resource "gitsync_values_yaml" "elk" {
  branch  = "master"
  path    = "gasx/elk/values.yaml"
  content = <<EOT
name: ${local.eks_elk_name}
nodeIamRoleName: ${module.eks-elk.node_iam_role_name}
eck-operator:
  replicaCount: 3
EOT
}

resource "gitsync_values_yaml" "internal-01-admin" {
  branch  = "master"
  path    = "gasx/internal-01/values.yaml"
  content = <<EOT
name: ${local.eks_internal_01_name}
nodeIamRoleName: ${module.eks-internal-01.node_iam_role_name}
hello-world:
  enabled: true
  replicaCount: 3
EOT
}

resource "gitsync_values_yaml" "internal-01" {
  provider = gitsync.poc
  branch  = "master"
  path    = "gasx/internal-01/values.yaml"
  content = <<EOT
name: ${local.eks_internal_01_name}
EOT
}
