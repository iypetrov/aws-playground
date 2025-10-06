locals {
  vpc_name = "vpc-with-valkey"
  vpc_cidr = "10.0.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.2.0"

  name = local.vpc_name
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

  elasticache_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 7),
    cidrsubnet(local.vpc_cidr, 8, 8),
    cidrsubnet(local.vpc_cidr, 8, 9)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Name = local.vpc_name
  }
}

