# x509-certificate-exporter (Metriken & Dashboard)

[x509-certificate-exporter](https://github.com/enix/x509-certificate-exporter) ist ein Prometheus Exporter, mit dem X.509-Zertifikate überwacht werden können.

## 0. Vorraussetzungen
- [helm](https://helm.sh/docs/intro/install/)

#### Helm Repo hinzufügen ODER
```
helm repo add enix https://charts.enix.io
```

#### aktualisieren
```
helm repo update enix
```

## k8s-monitoring (Helm Chart) installieren
```
helm upgrade --install x509-certificate-exporter enix/x509-certificate-exporter --namespace monitoring --version 3.19.1 --values x509-certificate-exporter-values.yaml
```