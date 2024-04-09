spacelift-init:
	terraform -chdir=spacelift/init apply

spacelift-rm:
	terraform -chdir=spacelift/init destroy

argocd-init:
	rm -rf kubernetes/environments/operator/argocd/argocd
	helm template kubernetes/charts/argocd --name-template argocd --namespace argocd --output-dir kubernetes/environments/operator/argocd
	kubectl apply --namespace argocd -f kubernetes/environments/operator/argocd/argocd/templates/namespace.yaml
	kubectl apply --namespace argocd -R -f kubernetes/environments/operator/argocd/argocd
	terraform -chdir=argocd/init apply

argocd-rm:
	kubectl delete --namespace argocd -R -f kubernetes/environments/operator/argocd/argocd

charts:
	rm -rf kubernetes/environments/operator/tailscale-operator/tailscale-operator
	helm template kubernetes/charts/tailscale-operator \
		-f kubernetes/charts/tailscale-operator/operator-values.yaml \
		--name-template tailscale-operator \
		--namespace tailscale-operator \
		--output-dir kubernetes/environments/operator/tailscale-operator

	rm -rf kubernetes/environments/staging/tailscale-operator/tailscale-operator
	helm template kubernetes/charts/tailscale-operator \
		-f kubernetes/charts/tailscale-operator/staging-values.yaml \
		--name-template tailscale-operator \
		--namespace tailscale-operator \
		--output-dir kubernetes/environments/staging/tailscale-operator

	rm -rf kubernetes/environments/operator/cert-manager/cert-manager
	helm template kubernetes/charts/cert-manager \
		-f kubernetes/charts/cert-manager/operator-values.yaml \
		--name-template cert-manager \
		--namespace cert-manager \
		--output-dir kubernetes/environments/operator/cert-manager

	rm -rf kubernetes/environments/staging/cert-manager/cert-manager
	helm template kubernetes/charts/cert-manager \
		-f kubernetes/charts/cert-manager/staging-values.yaml \
		--name-template cert-manager \
		--namespace cert-manager \
		--output-dir kubernetes/environments/staging/cert-manager