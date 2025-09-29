locals {
  eks_name    = "eks-argocd"
  k8s_version = "1.33"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = local.eks_name
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

  tags = {
    Name = local.eks_name
  }
}
