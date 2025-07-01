Bereitstellung basiert auf folgender Anleitung:
https://grafana.com/docs/loki/latest/setup/install/helm/deployment-guides/azure/

Vorraussetzungen:
- helm 
- kubectl
- Azure CLI


## Aktivieren Workload Identity und OIDC Issuer
```
az aks update \
  --resource-group <MY_RESOURCE_GROUP_NAME> \
  --name <MY_AKS_CLUSTER_NAME> \
  --enable-workload-identity \
  --enable-oidc-issuer
  ```

  ## Konfigurieren Blob Storage
  ```
az storage account create \
--name <NAME> \
--location <REGION> \
--sku Standard_ZRS \
--encryption-services blob \
--resource-group <MY_RESOURCE_GROUP_NAME>
  ```

  ## Container für Chunk und Ruler
  ```
az storage container create --account-name <STORAGE-ACCOUNT-NAME> --name <CHUNK-BUCKET-NAME> --auth-mode login && \
az storage container create --account-name <STORAGE-ACCOUNT-NAME> --name <RULER-BUCKET-NAME> --auth-mode login
````

## Create Azure AD role and credentials
```
az aks show \
--resource-group <MY_RESOURCE_GROUP_NAME> \
--name <MY_AKS_CLUSTER_NAME> \
--query "oidcIssuerProfile.issuerUrl" \
-o tsv
````

enerate a credentials.json file with the following content:

```
{
    "name": "LokiFederatedIdentity",
    "issuer": "<OIDC-ISSUER-URL>",
    "subject": "system:serviceaccount:loki:loki",
    "description": "Federated identity for Loki accessing Azure resources",
    "audiences": [
      "api://AzureADTokenExchange"
    ]
}
```
## Azure Directory App
```
 az ad app create \
 --display-name loki \
 --query appId \
 -o tsv

 az ad app list --display-name loki --query "[].appId" -o tsv
 ```

 