locals {
  k8s_name    = "cert-manager-aws-alb-ctrl"
  k8s_version = "1.35"

  k8s_addons = {
    cert_manager = "v1.19.3-eksbuild.2"
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
    cert-manager = {
      addon_version = local.k8s_addons.cert_manager
    }
  }

  tags = {
    Name = local.k8s_name
  }
}
