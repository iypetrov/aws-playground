# Istio PoC

### Bootstrap

```bash
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm install istio-base istio/base \
  -n istio-system \
  --create-namespace \
  --wait \
  --version 1.29.0

helm install istiod istio/istiod \
  -n istio-system \
  --set profile=ambient \
  --wait \
  --version 1.29.0

helm install istio-cni istio/cni \
  -n istio-system \
  --set profile=ambient \
  --wait \
  --version 1.29.0

helm install ztunnel istio/ztunnel \
  -n istio-system \
  --wait \
  --version 1.29.0

helm install istio-ingress istio/gateway \
  -n istio-ingress \
  --wait \
  --version 1.29.0
```

### Demo Setup

### References

- https://istio.io/latest/docs/ambient/install/helm/

- https://istio.io/latest/docs/ops/integrations/loadbalancers/

- https://aws.amazon.com/blogs/containers/secure-end-to-end-traffic-on-amazon-eks-using-tls-certificate-in-acm-alb-and-istio/

- https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/4045

- https://aws.amazon.com/blogs/opensource/achieving-zero-trust-security-on-amazon-eks-with-istio/#:~:text=allowed%20(by%20default)-,Ingress%20Gateway%20Certificate%20Management,as%20certificate%20management%20and%20renewal.

- https://github.com/aws-samples/eks-alb-istio-with-tls

- https://rutube.ru/video/7359d8f145390372581d30fba91a48aa

- https://aws.amazon.com/blogs/containers/migrating-from-aws-app-mesh-to-amazon-vpc-lattice

- https://oneuptime.com/blog/post/2026-02-24-how-to-use-aws-acm-certificates-with-istio/view
