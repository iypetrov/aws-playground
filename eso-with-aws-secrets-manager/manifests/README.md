# External Secrets Operator with AWS Secrets Manager

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets -n external-secrets --set serviceAccount.create=false --set serviceAccount.name=external-secrets --version 1.0.0
```
