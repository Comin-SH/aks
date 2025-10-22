# TransferService Loki Stack (Production)

Unser Loki Stack besteht derzeit aus den folgenden zwei Komponenten (helm Charts):
- [Loki | GitHub Repository](https://github.com/grafana/loki)
- [k8s-monitoring mit Alloy | GitHub Repository](https://github.com/grafana/k8s-monitoring-helm)

Er wird selbst gehostet und besitzt somit keine Abhängigkeit zu unserem Cloud Provider (Azure).  
Zu diesen Komponenten kommen noch weitere Abhängigkeiten (helm Charts) dazu. Details dazu gibts in den jeweiligen aufgesplittenen Dokumentationen.

## 0. Vorraussetzungen
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)

## 1. Variablen setzen
```
$STORAGE_ACCOUNT_NAME='blobcitfsprod' # Name des Storage Accounts
$RESOURCE_GROUP='Kubernetes' # Name der Ressourcengruppe, in dem sich das AKS Cluster befindet
$CLUSTER_NAME='TransferService' # Name des AKS Clusters
$WORKLOAD_IDENTITY_NAME='ci-tfs-prod' # Name der Workload Identity
```

## 2. Vorbereitungen in Azure
### 2.1. Container (Buckets) für Loki erstellen
> Dieser Schritt kann übersprungen werden, wenn die Workload Identity bereits existiert.

```
az storage container create --account-name $STORAGE_ACCOUNT_NAME --name chunks --auth-mode login
az storage container create --account-name $STORAGE_ACCOUNT_NAME --name ruler --auth-mode login
```

### 2.2. Service Account für Loki mit Workload Identity verknüpfen
> Standardmäßig wird über die Helm Chart `grafana/loki` ein Service Account mit dem Namen des Helm Releases erstellt. In unserem Fall `loki` im Namespace `monitoring`.

```
$AKS_OIDC_ISSUER=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)
$FEDERATED_CREDENTIAL_NAME='monitoring-loki'
$FEDERATED_CREDENTIAL_SUBJECT='system:serviceaccount:monitoring:loki'
az identity federated-credential create --name $FEDERATED_CREDENTIAL_NAME --identity-name $WORKLOAD_IDENTITY_NAME --resource-group $RESOURCE_GROUP --issuer $AKS_OIDC_ISSUER --subject $FEDERATED_CREDENTIAL_SUBJECT
```

## 3. Loki (Helm Chart)
### 3.1. Helm Repository
#### Repo hinzufügen ODER
```
helm repo add grafana https://grafana.github.io/helm-charts
```

#### Repo aktualisieren
```
helm repo update grafana
```

### 3.2. Loki installieren
```
helm upgrade --install loki grafana/loki --namespace monitoring --version 6.38.0 --values loki-values.yaml
```

## 4. Weitere Abhängigkeiten
### 4.1. k8s-monitoring (Alloy)
Als nächstes wird k8s-monitoring mit Alloy installiert. Details sind der [k8s-monitoring Dokumentation](k8s-monitoring/README.md) zu entnehmen.