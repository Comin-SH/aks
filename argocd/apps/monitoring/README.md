# TransferService Monitoring Stack (Production)

Unser Monitoring Stack besteht derzeit aus den folgenden zwei Hauptkomponenten (helm Charts):
- [kube-prometheus-stack | GitHub Repository](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [loki | GitHub Repository](https://github.com/grafana/loki)

Er wird selbst gehostet und besitzt somit keine Abhängigkeit zu unserem Cloud Provider (Azure).  
Zu diesen Komponenten kommen noch weitere Abhängigkeiten (helm Charts) dazu. Details dazu gibts in den jeweiligen aufgesplittenen Dokumentationen.

## 0. Vorraussetzungen
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)

## 1. Variablen setzen
```
$RESOURCE_GROUP='Kubernetes' # Name der Ressourcengruppe, in dem sich das AKS Cluster befindet
$CLUSTER_NAME='TransferService' # Name des AKS Clusters
$WORKLOAD_IDENTITY_NAME='ci-tfs-prod' # Name der Workload Identity
$STORAGE_ACCOUNT_NAME='blobcitfsprod' # Name des Storage Accounts
$KEYVAULT_NAME='ci-tfs-prod' # Name des Key Vaults
```

## 2. Vorbereitungen in Azure
### 2.1. Workload Identity und OIDC Issuer
#### Für ein bestehendes AKS Cluster "Workload Identity" und "OIDC Issuer" aktivieren
> Diese beiden Features am AKS Cluster werden für die aktuelle Umsetzung / Konfiguration benötigt.

> Dieser Schritt kann übersprungen werden, wenn diese Features bereits aktiviert sind.
```
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --enable-workload-identity --enable-oidc-issuer
```
v
### 2.2. Workload Identity
#### Workload Identity (Managed Identity) für den späteren Zugriff auf den Key Vault erstellen
> Die Workload Identity wird später von Grafana für den Zugriff auf den Key Vault und von Loki für den Zugriff auf den Blob Storage benötigt.

> Dieser Schritt kann übersprungen werden, wenn die Workload Identity bereits existiert.
```
az identity create --name $WORKLOAD_IDENTITY_NAME --resource-group $RESOURCE_GROUP
```

### 2.3. Blob Storage
#### Für ein bestehendes AKS Cluster "Blob Driver" aktivieren
> Dieser Schritt kann übersprungen werden, wenn der Blob Driver bereits aktiviert oder eine Open Source Variante vorhanden ist.

```
az aks update --enable-blob-driver --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

#### Storage Account mit Blob Storage erstellen
> Der Blob Storage wird später von Loki benötigt.

> Dieser Schritt kann übersprungen werden, wenn der Storage Account bereits existiert.
```
$STORAGE_ACCOUNT_LOCATION='germanywestcentral'
$STORAGE_ACCOUNT_SKU='Standard_LRS'
az storage account create --name $STORAGE_ACCOUNT_NAME --location $STORAGE_ACCOUNT_LOCATION --sku $STORAGE_ACCOUNT_SKU --encryption-services blob --resource-group $RESOURCE_GROUP
```

#### Rechte zum Schreiben in den Blob Storage setzen
> Dieser Schritt kann übersprungen werden, wenn die Rechte bereits gesetzt sind.
```
$WORKLOAD_IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $WORKLOAD_IDENTITY_NAME --query 'clientId' -o tsv)
$STORAGE_ACCOUNT_SCOPE=$(az storage account show --name $STORAGE_ACCOUNT_NAME --query id -o tsv)
az role assignment create --role "Storage Blob Data Contributor" --assignee $WORKLOAD_IDENTITY_CLIENT_ID --scope $STORAGE_ACCOUNT_SCOPE
```

### 2.4. Secrets Store CSI Driver
#### Für ein bestehendes AKS Cluster den Azure Key Vault Provider für den Secrets Store CSI Driver aktivieren
> Der Secrets Store CSI Driver wird später von Grafana für den Zugriff auf den Key Vault benötigt.

> Dieser Schritt kann übersprungen werden, wenn der Secrets Store CSI Driver bereits aktiviert ist.
```
az aks enable-addons --addons azure-keyvault-secrets-provider --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
```

#### Überprüfen, ob die Aktivierung erfolgreich war und alle zugehörigen Pods laufen
> Dieser Schritt kann übersprungen werden, wenn der Secrets Store CSI Driver bereits aktiviert ist.
```
kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)'
```

### 2.5. Azure Key Vault
#### Key Vault erstellen
> Dieser Schritt kann übersprungen werden, wenn ein Key Vault bereits existiert.
```
$KEYVAULT_LOCATION='germanywestcentral'
az keyvault create --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP --location $KEYVAULT_LOCATION --sku standard --enable-rbac-authorization
```

#### Dem aktuellen / ausführenden Nutzer "Key Vault Administrator" Rechte geben
> Obwohl man gerade selbst das Key Vault angelegt hat, besitzt man u.a. keine Rechte um Secrets zu erstellen. Im späteren Verlauf benötigen wir aber diese Rechte.  
> Das ändern wir, indem wir uns selbst die Rolle "Key Vault Administrator" geben.
```
$SIGNED_IN_USER_ID=$(az ad signed-in-user show --query id -o tsv)
$KEYVAULT_SCOPE=$(az keyvault show --name $KEYVAULT_NAME --query id -o tsv)
az role assignment create --role "Key Vault Administrator" --assignee $SIGNED_IN_USER_ID --scope $KEYVAULT_SCOPE
```

#### Rechte zum Abrufen von Secrets setzen
> Die Rolle "Key Vault Secrets User" ermöglicht lediglich das Abrufen von Secrets. Keys und Zertifikate können damit nicht abgerufen werden.
> Dafür muss die Rolle "Key Vault Certificate User" verwendet werden.

> Dieser Schritt kann übersprungen werden, wenn die Rechte bereits gesetzt sind.
```
$WORKLOAD_IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $WORKLOAD_IDENTITY_NAME --query 'clientId' -o tsv)
$KEYVAULT_SCOPE=$(az keyvault show --name $KEYVAULT_NAME --query id -o tsv)
az role assignment create --role "Key Vault Secrets User" --assignee $WORKLOAD_IDENTITY_CLIENT_ID --scope $KEYVAULT_SCOPE
```
> Hinweis: Das Recht kann auch über das Portal geprüft oder gesetzt werden (Key Vault > Access control (IAM) > Role assignments > Key Vault Secrets User / Key Vault Certificate User)

## 3. Loki installieren
An diesem Punkt sind die groben Vorbereitungen in Azure abgearbeitet und es kann nun mit Loki weitergehen. Details sind der [Loki Dokumentation](loki/README.md) zu entnehmen.

## 4. kube-prometheus-stack installieren
Als nächstes wird der kube-prometheus-stack installiert. Details sind der [kube-prometheus-stack Dokumentation](kube-prometheus-stack/README.md) zu entnehmen.