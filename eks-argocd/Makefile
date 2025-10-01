bootstrap:
	@kubectl create namespace argocd
	@kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml -n argocd

# kubectl port-forward svc/argocd-server -n argocd 8080:443
add:
	@argocd login localhost:8080 --username admin --password "$$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" --insecure
	@argocd repo add https://innersource.soprasteria.com/ENER-GXrestricted/infrastructure/apps.git --username ilia.petrov --password some-token
	# Go to the apps repo and manually apply the application manifest
