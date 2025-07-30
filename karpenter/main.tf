locals {
  vpc_cidr        = "10.1.0.0/16"
  cluster_name    = "karpenter-cluster"
  cluster_version = "1.33"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.cluster_name
  cidr = local.vpc_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 0),
    cidrsubnet(local.vpc_cidr, 8, 1),
  ]
  private_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 2),
    cidrsubnet(local.vpc_cidr, 8, 3)
  ]
  intra_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 4),
    cidrsubnet(local.vpc_cidr, 8, 5)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.cluster_name
  }

  tags = {
    Name = local.cluster_name
  }
}

locals {
  eks_config = {
    cluster_name    = local.cluster_name
    cluster_version = local.cluster_version
    vpc_id          = module.vpc.vpc_id
    subnet_ids      = module.vpc.public_subnets

    nodes = {
      "nodegroup-1" = {
        min_size       = 1
        max_size       = 3
        desired_size   = 2
        instance_types = ["t3.medium"]
        az             = "${var.aws_region}a"
      }
      "nodegroup-2" = {
        min_size       = 2
        max_size       = 4
        desired_size   = 3
        instance_types = ["t3.large"]
        az             = "${var.aws_region}b"
      }
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.5"

  name               = local.eks_config.cluster_name
  kubernetes_version = local.eks_config.cluster_version

  vpc_id     = local.eks_config.vpc_id
  subnet_ids = local.eks_config.subnet_ids

  eks_managed_node_groups = {
    nodegroup-1 = {
      min_size           = local.eks_config.nodes["nodegroup-1"].min_size
      max_size           = local.eks_config.nodes["nodegroup-1"].max_size
      desired_size       = local.eks_config.nodes["nodegroup-1"].desired_size
      instance_type      = local.eks_config.nodes["nodegroup-1"].instance_types[0]
      availability_zones = [local.eks_config.nodes["nodegroup-1"].az]
      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
    nodegroup-2 = {
      min_size           = local.eks_config.nodes["nodegroup-2"].min_size
      max_size           = local.eks_config.nodes["nodegroup-2"].max_size
      desired_size       = local.eks_config.nodes["nodegroup-2"].desired_size
      instance_type      = local.eks_config.nodes["nodegroup-2"].instance_types[0]
      availability_zones = [local.eks_config.nodes["nodegroup-2"].az]
      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }
}
