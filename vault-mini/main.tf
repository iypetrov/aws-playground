locals {
  name        = "eks-external-dns"
  vpc_cidr    = "10.0.0.0/16"
  k8s_version = "1.34"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = local.name
  cidr = local.vpc_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  private_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 1),
    cidrsubnet(local.vpc_cidr, 8, 2),
    cidrsubnet(local.vpc_cidr, 8, 3)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 4),
    cidrsubnet(local.vpc_cidr, 8, 5),
    cidrsubnet(local.vpc_cidr, 8, 6)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "Name"                   = "${local.name}-public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "${local.name}-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name = local.name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = local.name
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
    Name = local.name
  }
}
