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

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = module.eks.cluster_name

  enable_v1_permissions = true

  enable_irsa = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_pod_identity = true
  create_pod_identity_association = true

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "1.0.6"
  wait                = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    EOT
  ]
}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  ttlSecondsAfterEmpty: 60 # scale down nodes after 60 seconds without workloads (excluding daemons)
  ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
  limits:
    resources:
      cpu: 100 # limit to 100 CPU cores
  requirements:
    # Include general purpose instance families
    - key: karpenter.k8s.aws/instance-family
      operator: In
      values: [t3, c5, m5, r5]
    # Exclude small instance sizes
    - key: karpenter.k8s.aws/instance-size
      operator: NotIn
      values: [nano, micro, small]
  providerRef:
    name: default
YAML
}

# resource "kubectl_manifest" "karpenter_template" {
#   yaml_body = <<-YAML
# ---
# apiVersion: karpenter.k8s.aws/v1alpha1
# kind: AWSNodeTemplate
# metadata:
#     name: default
# spec:
#   subnetSelector:
#     "kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
#   securityGroupSelector:
#     "kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
#   instanceProfile: ${module.karpenter.instance_profile_name}
#   tags:
#     "kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
# YAML
# }
