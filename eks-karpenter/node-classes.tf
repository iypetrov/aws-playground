resource "kubectl_manifest" "karpenter_ec2nodeclass_proxy" {
  depends_on = [
    helm_release.karpenter
  ]

  yaml_body = <<-EOF
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: proxy
spec:
  amiSelectorTerms:
    - alias: al2023@v20250807
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
    karpenter.sh/discovery: ${local.eks_name}
EOF
}
