# TransferService kube-prometheus-stack (Production)

kube-prometheus-stack besteht derzeit aus mehrere Komponenten, welche am besten vorher installiert werden.

## 0. Vorraussetzungen
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)

## 1. Vorbereitungen für Grafana
Für Grafana (eine Teilkomponente von kube-prometheus-stack) müssen noch einige Vorbereitungen getroffen werden.

### 1.1. grafana-admin-credentials
Die Zugangsdaten für Grafana werden im Azure Key Vault abgelegt. Details sind der [grafana-admin-credentials Dokumentation](grafana/admin-credentials/README.md) zu entnehmen.

### 1.2. Eigene Dashboards
Es können eigene Dashboards in Grafana importiert werden. Diese werden im Verzeichnis `grafana/custom-dashboards` abgelegt.  
Derzeit gibt es nur ein Dashboard für die TransferService Logs:
- ```
  kubectl apply -f grafana/custom-dashboards/transferservice-logs.yaml
  ```

## 2. kube-prometheus-stack (Helm Chart)
### 2.1. Helm Repository
#### Repo hinzufügen ODER
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

#### Repo aktualisieren
```
helm repo update prometheus-community
```

### 2.2. kube-prometheus-stack installieren
```
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --version 77.0.2 --values kube-prometheus-stack-values.yaml
```

### 2.3. x509-certificate-exporter
Mit x509-certificate-exporter können Zertifikate überwacht werden. Details sind der [x509-certificate-exporter Dokumentation](grafana/x509-certificate-exporter/README.md) zu entnehmen.  
Dadurch, dass x509-certificate-exporter eine Abhängigkeit zu kube-prometheus-stack hat, muss dieser Schritt nach der Installation von kube-prometheus-stack ausgeführt werden.