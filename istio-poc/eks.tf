locals {
  k8s_name    = "istio-poc"
  k8s_version = "1.35"

  k8s_addons = {
    metrics_server = "v0.8.1-eksbuild.1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = local.k8s_name
  kubernetes_version = local.k8s_version

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  create_auto_mode_iam_resources = true
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  addons = {
    metrics-server = {
      addon_version = local.k8s_addons.metrics_server
    }
  }

  tags = {
    Name = local.k8s_name
  }
}
