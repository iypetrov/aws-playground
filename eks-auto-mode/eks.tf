locals {
  eks_name    = "eks-auto-v1"
  eks_version = "1.33"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = local.eks_name
  cluster_version = local.eks_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_compute_config = {
    enabled    = true
    node_pools = []
  }

  tags = {
    Name = local.eks_name
  }
}
