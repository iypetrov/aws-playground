locals {
  eks_name                       = "karpenter-v3"
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
    coredns = {
      version = local.coredns_version
      configuration_values = jsonencode({
        tolerations = [
          # Allow CoreDNS to run on the same nodes as the Karpenter controller
          # for use during cluster creation when Karpenter nodes do not yet exist
          {
            key    = "karpenter.sh/controller"
            value  = "true"
            effect = "NoSchedule"
          }
        ]
      })
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

  eks_managed_node_groups = {
    system = {
      min_size     = 1
      max_size     = 5
      desired_size = 3
      instance_types = [
        "t3.medium",
        "t3.large",
      ]
      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
      taints = {
        # The pods that do not tolerate this taint should run on nodes
        # created by Karpenter
        karpenter = {
          key    = "karpenter.sh/controller"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = "${local.eks_name}"
  }

  tags = {
    Name = local.eks_name
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

  enable_pod_identity             = true
  create_pod_identity_association = true

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = local.eks_name
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
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
    nodeSelector:
      karpenter.sh/controller: 'true'
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - key: karpenter.sh/controller
        operator: Exists
        effect: NoSchedule
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
