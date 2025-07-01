```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --version 75.6.1 --values values.yaml
```