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
  --create-namespace \
  -f values/ingress-values.yaml \
  --wait \
  --version 1.29.0
```

### Demo Setup

```bash
# 1. Apply manifests (cert-manager Certificate, nginx Deployment/Service, Istio Gateway, Waypoint)
kubectl apply -k manifests/

# 2. Enroll the default namespace in ambient mode
kubectl label namespace default istio.io/dataplane-mode=ambient

# 3. Point the app service at the waypoint so L7 policies are enforced
kubectl label namespace default istio.io/use-waypoint=waypoint

# 4. Verify waypoint is running
kubectl get gateway waypoint -n default
kubectl get pods -n default -l gateway.istio.io/managed=istio.io-mesh-controller

# 5. Confirm ambient enrollment (pods show 1/1, not 2/2)
kubectl get pods -n default
istioctl ztunnel-config workload -n default

# 6. Test routing (replace with your NLB hostname or DNS record)
curl -v https://app.cpx-lab52.de/nginx
```


don't forget to reapply terraform, route53
then run k rollout restart -n cert-manager deployment/cert-manager

### Traffic Flow

```
Internet (HTTPS:443)
  │
  ▼
AWS NLB  ← provisioned by AWS LB Controller via istio-ingress Service annotations
  │  raw TCP passthrough
  ▼
Istio IngressGateway (istio-ingress ns, port 443)
  │  terminates TLS — cert from cert-manager (app-cpx-lab52-de-tls)
  │  VirtualService: /nginx → rewrite / → app.default.svc.cluster.local:80
  │  mTLS via ztunnel (HBONE port 15008)
  ▼
Waypoint proxy (default ns)
  │  L7: AuthorizationPolicy, retries, metrics per service
  ▼
nginx pod (app Deployment, port 80)
```

### References

- https://istio.io/latest/docs/ambient/architecture/

- https://oneuptime.com/blog/post/2026-02-24-how-to-configure-istio-with-aws-nlb/view

- https://istio.io/latest/docs/ambient/usage/waypoint/
