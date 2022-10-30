init-k8-cluster: install-nginx-ingress install-cert-manager install-prometheus-operator

init-app:
# crea el namespace si no existe
	kubectl apply -f ./src/namespace.yaml
# crea la instancia de rabbitmq en el namespace creado anteriormente
	kubectl apply -f ./src/rabbitmq.yaml -n jperez

install-nginx-ingress:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
# instala el nginx ingress-controller en el namespace ingress-nginx
# recuerde tener deshabilitado el traefik de RancherDesktop antes de ejecutar.
	helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

install-cert-manager:

	helm upgrade --install cert-manager cert-manager --repo https://charts.jetstack.io --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
	kubectl apply -f resources/self-sign-cluster-issuer.yaml


install-prometheus-operator:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update prometheus-community
	helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
# ingress para el monitoreo
	kubectl apply -f ./resources/monitoring-ingress.yaml -n monitoring
# monitoreo para cert manager
	kubectl apply -f ./resources/cert-manager-serviceMonitor.yaml -n monitoring
# dashboard para rabbitmq
	kubectl apply -f ./resources/rabbitmq-dashboard.yaml -n monitoring
# dashboard para asp.net
	kubectl apply -f ./resources/aspnet-dashboard.yaml -n monitoring
# dashboard para masstransit
	kubectl apply -f ./resources/masstransit-dashboard.yaml -n monitoring

