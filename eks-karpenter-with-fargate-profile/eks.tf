locals {
  eks_name                       = "karpenter-v4"
  eks_version                    = "1.33"
  karpenter_namespace            = "karpenter"
  karpenter_version              = "1.0.6"
  coredns_version                = "v1.11.4-eksbuild.10"
  eks_pod_identity_agent_version = "v1.3.7-eksbuild.2"
  kube_proxy_version             = "v1.32.3-eksbuild.7"
  vpc_cni_version                = "v1.19.5-eksbuild.1"
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
    # Enable after creation to run on Karpenter managed nodes
    coredns = {
      version = local.coredns_version
    }
    eks-pod-identity-agent = {
      version = local.eks_pod_identity_agent_version
    }
    kube-proxy = {
      version = local.kube_proxy_version
    }
    vpc-cni = {
      version = local.vpc_cni_version
    }
  }

  # Fargate profiles use the cluster primary security group
  # Therefore these are not used and can be skipped
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = local.karpenter_namespace }
      ]
    }
  }

  tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.eks_name
  }
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = module.eks.cluster_name

  enable_v1_permissions = true
  namespace             = local.karpenter_namespace

  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Fargate does not support pod identity
  create_pod_identity_association = false

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = local.eks_name
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.ecr
}

resource "helm_release" "karpenter" {
  name                = "karpenter"
  namespace           = local.karpenter_namespace
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  create_namespace    = true
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = local.karpenter_version
  wait                = false

  values = [
    <<-EOT
    dnsPolicy: Default
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    webhook:
      enabled: false
    EOT
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}
