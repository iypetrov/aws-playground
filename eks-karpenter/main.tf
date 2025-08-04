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
    "karpenter.sh/discovery"                  = "${local.eks_name}"
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
    vpc-cni = {
      configuration_values = jsonencode({
        enableWindowsIpam = "true"
      })
    }
  }

  eks_managed_node_groups = {
    bootstrap = {
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
  }

  node_security_group_tags = {
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

  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_pod_identity             = true
  create_pod_identity_association = true

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.0.6"
  wait       = false

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

resource "kubectl_manifest" "karpenter_ec2nodeclass_workloads" {
  depends_on = [
    helm_release.karpenter
  ]

  yaml_body = <<-EOF
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: workloads
spec:
  amiSelectorTerms:
    - alias: al2023@latest
  role: ${module.karpenter.node_iam_role_name}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${local.eks_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${local.eks_name}
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
        iops: 10000
        deleteOnTermination: true
        throughput: 125
  tags:
    team: workloads
EOF
}

resource "kubectl_manifest" "karpenter_nodepool_workloads" {
  depends_on = [
    helm_release.karpenter
  ]

  yaml_body = <<-EOF
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: workloads
spec:
  template:
    metadata:
      labels:
        nodegroup: workloads
    spec:
      nodeClassRef:
        name: workloads
        group: karpenter.k8s.aws
        kind: EC2NodeClass
      requirements:
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["m", "t", "c"]
        - key: karpenter.k8s.aws/instance-cpu
          operator: In
          values: ["2", "3", "4"]
        - key: karpenter.k8s.aws/instance-hypervisor
          operator: In
          values: ["nitro"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
        - key: topology.kubernetes.io/zone
          operator: In
          values: ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
  limits:
    cpu: 500
    memory: 500Gi
EOF
}
