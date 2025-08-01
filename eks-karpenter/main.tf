locals {
  vpc_cidr    = "10.2.0.0/16"
  vpc_name    = "vpc-karpenter-v1"
  eks_name    = "karpenter-v1"
  eks_version = "1.33"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

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

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"         = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
    "karpenter.sh/discovery" = "${local.eks_name}"
  }

  tags = {
    Name = local.vpc_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.eks_name
  cluster_version = local.eks_version

  enable_irsa = true

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    aws-ebs-csi-driver     = {}
    vpc-cni                = {
      configuration_values = jsonencode({
        enableWindowsIpam   = "true"
      })
    }
  }

  eks_managed_node_groups = {
    # it is not recommended to manege the Karpenter's control plane by Karpenter itself, should consider:
    # - use dedicated node group for Karpenter's control plane
    # - use Fargate for Karpenter's control plane
    control-plane = {
      min_size     = 1
      max_size     = 5
      desired_size = 3
      instance_types = [
        "t3.medium",
        "t3.large",
      ]
      labels = {
        "karpenter.sh/controller" = "true"
      }
    }

    workers = {
      min_size     = 3
      max_size     = 10
      desired_size = 5
      instance_types = [
        "t3.medium",
        "t3.large",
        "t3.xlarge",
      ]
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${local.eks_name}"
  }

  tags = {
    Name = local.eks_name
  }
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_id]
  }
}
