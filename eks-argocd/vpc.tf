locals {
  vpc_argocd_name = "vpc-argocd"
  vpc_argocd_cidr = "10.0.0.0/16"
  vpc_elk_name = "vpc-elk"
  vpc_elk_cidr = "10.1.0.0/16"
  vpc_internal_01_name = "vpc-internal-01"
  vpc_internal_01_cidr = "10.2.0.0/16"
}

module "vpc-argocd" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.2.0"

  name = local.vpc_argocd_name
  cidr = local.vpc_argocd_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  private_subnets = [
    cidrsubnet(local.vpc_argocd_cidr, 8, 1),
    cidrsubnet(local.vpc_argocd_cidr, 8, 2),
    cidrsubnet(local.vpc_argocd_cidr, 8, 3)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_argocd_cidr, 8, 4),
    cidrsubnet(local.vpc_argocd_cidr, 8, 5),
    cidrsubnet(local.vpc_argocd_cidr, 8, 6)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "Name"                   = "${local.eks_argocd_name}-public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "${local.eks_argocd_name}-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name = local.vpc_argocd_name
  }
}

module "vpc-elk" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.2.0"

  name = local.vpc_elk_name
  cidr = local.vpc_elk_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  private_subnets = [
    cidrsubnet(local.vpc_elk_cidr, 8, 1),
    cidrsubnet(local.vpc_elk_cidr, 8, 2),
    cidrsubnet(local.vpc_elk_cidr, 8, 3)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_elk_cidr, 8, 4),
    cidrsubnet(local.vpc_elk_cidr, 8, 5),
    cidrsubnet(local.vpc_elk_cidr, 8, 6)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "Name"                   = "${local.eks_elk_name}-public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "${local.eks_elk_name}-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name = local.vpc_elk_name
  }
}

module "vpc-internal-01" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.2.0"

  name = local.vpc_internal_01_name
  cidr = local.vpc_internal_01_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  private_subnets = [
    cidrsubnet(local.vpc_internal_01_cidr, 8, 1),
    cidrsubnet(local.vpc_internal_01_cidr, 8, 2),
    cidrsubnet(local.vpc_internal_01_cidr, 8, 3)
  ]

  public_subnets = [
    cidrsubnet(local.vpc_internal_01_cidr, 8, 4),
    cidrsubnet(local.vpc_internal_01_cidr, 8, 5),
    cidrsubnet(local.vpc_internal_01_cidr, 8, 6)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "Name"                   = "${local.vpc_internal_01_name}-public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name"                            = "${local.vpc_internal_01_name}-private-subnet"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name = local.vpc_internal_01_name
  }
}
