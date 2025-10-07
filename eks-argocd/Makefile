bootstrap:
	@kubectl create namespace argocd
	@helm repo add argo https://argoproj.github.io/argo-helm
	@helm repo update
	@helm install argocd -n argocd --set server.extraArgs="{--insecure}" argo/argo-cd

# kubectl port-forward svc/argocd-server -n argocd 8080:443
add-repos:
	@argocd login localhost:8080 --username admin --password "$$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" --insecure
	@argocd repo add https://innersource.soprasteria.com/ENER-GXrestricted/infrastructure/apps.git --username ilia.petrov --password some-token
	@argocd repo add https://innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/apps-poc.git --username ilia.petrov --password some-token
	# Go to the apps repo and manually apply the application manifest
	
add-cluster:
	@argocd cluster add $(CLUSTER)
