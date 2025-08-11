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
