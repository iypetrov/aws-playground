locals {
  eks_config = {
    cluster_name    = "karpenter-cluster"
    cluster_version = "1.33"
    vpc_id          = aws_vpc.vpc.id
    subnet_ids = [
      aws_subnet.private_subnet_a.id,
      aws_subnet.private_subnet_b.id
    ]
    security_group_ids = [
      aws_security_group.sg_1.id
    ]

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
  version = "20.30.1"

  cluster_name    = "karpenter-cluster"
  cluster_version = "1.33"

  vpc_id     = local.eks_config.vpc_id
  subnet_ids = local.eks_config.subnet_ids

  eks_managed_node_groups = {
    nodegroup-1 = {
      min_size           = local.eks_config.nodes["nodegroup-1"].min_size
      max_size           = local.eks_config.nodes["nodegroup-1"].max_size
      desired_size       = local.eks_config.nodes["nodegroup-1"].desired_size
      instance_type      = local.eks_config.nodes["nodegroup-1"].instance_types[0]
      availability_zones = [local.eks_config.nodes["nodegroup-1"].az]
    }
    nodegroup-2 = {
      min_size           = local.eks_config.nodes["nodegroup-2"].min_size
      max_size           = local.eks_config.nodes["nodegroup-2"].max_size
      desired_size       = local.eks_config.nodes["nodegroup-2"].desired_size
      instance_type      = local.eks_config.nodes["nodegroup-2"].instance_types[0]
      availability_zones = [local.eks_config.nodes["nodegroup-2"].az]
    }
  }
}
