# k8s-monitoring mit Alloy

Logs werden mit Alloy an Loki weitergeleitet. Alloy ist ein Teil der [k8s-monitoring Helm Chart von Grafana](https://github.com/grafana/k8s-monitoring-helm).

## Vorraussetzungen
- [helm](https://helm.sh/docs/intro/install/)

#### Helm Repo hinzufügen ODER
```
helm repo add grafana https://grafana.github.io/helm-charts
```

#### aktualisieren
```
helm repo update grafana
```

## k8s-monitoring (Helm Chart) installieren
```
helm upgrade --install k8s-monitoring grafana/k8s-monitoring --namespace monitoring --version 3.3.2 --values k8s-monitoring-values.yaml
```