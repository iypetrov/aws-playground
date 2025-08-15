locals {
  eks_name                       = "karpenter-v4"
  eks_version                    = "1.33"
  karpenter_namespace            = "karpenter"
  karpenter_version              = "1.6.1"
  coredns_version                = "v1.12.2-eksbuild.4"
  eks_pod_identity_agent_version = "v1.3.8-eksbuild.2"
  kube_proxy_version             = "v1.33.3-eksbuild.4"
  vpc_cni_version                = "v1.20.1-eksbuild.1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.2"

  cluster_name    = local.eks_name
  cluster_version = local.eks_version

  enable_irsa = true

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      addon_version = local.coredns_version
      configuration_values = jsonencode({
        # computeType = "Fargate"
        # Ensure that the we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targetting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
    eks-pod-identity-agent = {
      addon_version = local.eks_pod_identity_agent_version
    }
    kube-proxy = {
      addon_version = local.kube_proxy_version
    }
    vpc-cni = {
      addon_version = local.vpc_cni_version
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
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
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
  version = "20.37.2"

  cluster_name = module.eks.cluster_name

  access_entry_type = "FARGATE_LINUX"

  enable_v1_permissions = true
  namespace             = local.karpenter_namespace

  enable_irsa             = true
  create_instance_profile = true
  irsa_oidc_provider_arn  = module.eks.oidc_provider_arn

  # EKS Fargate does not support pod identity
  create_pod_identity_association = false

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
