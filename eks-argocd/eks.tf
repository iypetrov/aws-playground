locals {
  eks_argocd_name    = "eks-argocd"
  k8s_argocd_version = "1.33"
  eks_elk_name    = "eks-elk"
  k8s_elk_version = "1.33"
  eks_internal_01_name    = "eks-internal-01"
  k8s_internal_01_version = "1.33"
}

module "eks-argocd" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = local.eks_argocd_name
  kubernetes_version = local.k8s_argocd_version

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  create_auto_mode_iam_resources = true
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc-argocd.vpc_id
  subnet_ids = module.vpc-argocd.private_subnets

  tags = {
    Name = local.eks_argocd_name
  }
}

module "eks-elk" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = local.eks_elk_name
  kubernetes_version = local.k8s_elk_version

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  create_auto_mode_iam_resources = true
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc-elk.vpc_id
  subnet_ids = module.vpc-elk.private_subnets

  tags = {
    Name = local.eks_elk_name
  }
}

module "eks-internal-01" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.1"

  name               = local.eks_internal_01_name
  kubernetes_version = local.k8s_internal_01_version

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  create_auto_mode_iam_resources = true
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = module.vpc-internal-01.vpc_id
  subnet_ids = module.vpc-internal-01.private_subnets

  tags = {
    Name = local.eks_internal_01_name
  }
}
