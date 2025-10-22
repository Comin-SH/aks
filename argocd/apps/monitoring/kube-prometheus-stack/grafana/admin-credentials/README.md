# Grafana Admin Credentials aus Azure Key Vault beziehen

Die originale und ausführlichere Konfiguration ist hier zu finden:
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
- https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access?tabs=azure-portal&pivots=access-with-a-microsoft-entra-workload-identity

Und hier für die automatische Erstellung von Kubernetes Secrets aus Azure Key Vault Secrets: https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options#sync-mounted-content-with-a-kubernetes-secret

## 0. Vorraussetzungen
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [helm](https://helm.sh/docs/intro/install/)

## 1. Benötigte Variablen setzen
```
$RESOURCE_GROUP='Kubernetes'
$CLUSTER_NAME='TransferService'
$KEYVAULT_NAME='ci-tfs-prod'
$WORKLOAD_IDENTITY_NAME='ci-tfs-prod'
```

## 2. Vorbereitungen in Azure
### Secret erstellen
> Dieser Schritt kann übersprungen werden, wenn ein Secret bereits existiert.
```
$SECRET_NAME='grafana-admin-user'
$SECRET_VALUE='admin'
az keyvault secret set --vault-name $KEYVAULT_NAME --name $SECRET_NAME --value $SECRET_VALUE

$SECRET_NAME='grafana-admin-password'
$SECRET_VALUE='MY_STRONG_SECRET'
az keyvault secret set --vault-name $KEYVAULT_NAME --name $SECRET_NAME --value $SECRET_VALUE
```
> Das führende Passwort kann jederzeit direkt aus dem Key Vault abgerufen werden (sowohl im Portal oder aber über die Azure CLI).  
> Zusätzlich befindet es sich für den schnelleren und einfacheren Zugriff in Vaultwarden: Transferservice Infrastruktur > KeyVault - ci-tfs-prod > grafana-admin-credentials

## 3. Vorbereitung des Service Accounts
### Service Account erstellen
Um von einem Pod aus auf den Key Vault zugreifen zu können, wird ein Kubernetes Service Account benötigt, der die Workload Identity verwendet. Pro Namespace gibt es den Service Account `default`, der für alle Pods im Namespace standardmäßig verwendet wird. Aus Sicherheitsgründen sollte dieser Service Account nicht für den Zugriff auf den Key Vault verwendet werden. Stattdessen sollte ein separater Service Account erstellt werden, der die Workload Identity verwendet.  
**Für Grafana (über kube-prometheus-stack) benötigen wir keinen eigenständige Service Account. Hier gibt es bereits den Service Account `monitoring/kube-prometheus-stack-grafana`.**

### Service Account mit Workload Identity verknüpfen
Im letzten Schritt muss die Workload Identity mit dem Service Account verknüpft werden. Hier am Beispiel des Service Accounts `monitoring/kube-prometheus-stack-grafana`:
```
$AKS_OIDC_ISSUER=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)
$FEDERATED_CREDENTIAL_NAME='monitoring-kube-prometheus-stack-grafana'
$FEDERATED_CREDENTIAL_SUBJECT='system:serviceaccount:monitoring:kube-prometheus-stack-grafana'
az identity federated-credential create --name $FEDERATED_CREDENTIAL_NAME --identity-name $WORKLOAD_IDENTITY_NAME --resource-group $RESOURCE_GROUP --issuer $AKS_OIDC_ISSUER --subject $FEDERATED_CREDENTIAL_SUBJECT
```

## 4. Verwendung in Kubernetes
### SecretProviderClass erstellen
Es wird eine SecretProviderClass benötigt, die den Zugriff auf den Key Vault und ein oder mehrere Secrets konfiguriert. Dort wird auch konfiguriert, dass die Secrets in Kubernetes synchronisiert (erstellt) werden sollen.
Beispiel für Grafana (über kube-prometheus-stack):
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: grafana-admin-credentials
  namespace: monitoring # Die Ressource muss in dem Namespace angelegt werden, indem sich später das synchronisierte Secret befinden soll
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: f64c420b-cc5a-45e4-934e-514b0962c461 # ID der Workload Identity, siehe $WORKLOAD_IDENTITY_CLIENT_ID
    keyvaultName: ci-tfs-prod # Name des Key Vaults, siehe $KEYVAULT_NAME
    objects:  |
      array:
        - |
          objectName: grafana-admin-user # Name des Secrets im Key Vault
          objectType: secret # Typ des Objekts im Key Vault (secret, key, certificate)
        - |
          objectName: grafana-admin-password # Name eines zweiten Secrets im Key Vault
          objectType: secret # Typ des zweiten Objekts im Key Vault (secret, key, certificate)
    tenantId: 5159fdaa-fc6b-46fc-a28e-8f6a27aa5862 # Die ID unseres Mandanten
  secretObjects: # Einstellungen für die Synchronisierung der Secrets in Kubernetes
  - data:
    - key: admin-user # Key des ersten Secrets in Kubernetes
      objectName: grafana-admin-user # Referenz auf das Secret im Key Vault (siehe den ersten objectName)
    - key: admin-password # Key des zweiten Secrets in Kubernetes
      objectName: grafana-admin-password # Referenz auf das Secret im Key Vault (siehe den zweiten objectName)
    secretName: grafana-admin-credentials # Name des anzulegenden Kubernetes Secrets
    type: Opaque # Typ des anzulegenden Kubernetes Secrets
```

> Siehe auch [secret-provider-class.yaml](secret-provider-class.yaml)

### Auf das Kubernetes Secret zugreifen
#### Grafana über kube-prometheus-stack
Noch wurde kein Kubernetes Secret erstellt. Das passiert erst, wenn ein Pod den SecretProviderClass verwendet.  
Für Grafana (über kube-prometheus-stack) ist folgende Konfiguration notwendig, damit das Secret automatisch erstellt wird und darauf zugegriffen werden kann:
```yaml
grafana:
  extraVolumeMounts:
    - name: grafana-secrets
      mountPath: /mnt/grafana-secrets
      readOnly: true
  extraVolumes:
    - name: grafana-secrets
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: grafana-admin-credentials
```
> Hinweis: Sowohl ein Volume, als auch ein VolumeMount sind notwendig