Quelle:
https://grafana.com/docs/loki/latest/setup/install/helm/deployment-guides/azure/

Setzen Variablen
```
sa_name=salokiafl
clustername=k8s
rg=k8s-rg
ad_app_name=loki-test-afl
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

```

Blob Storage aktivieren im Cluster
```
az aks update --enable-blob-driver --name $clustername --resource-group $rg
```

Erstellen Storage Account
```
az storage account create \
--name salokiafl \
--location "germanywestcentral" \
--sku Standard_ZRS \
--encryption-services blob \
--resource-group $rg
```

Erstellen Storage Container
```
az storage container create --account-name $sa_name --name chunk --auth-mode login
az storage container create --account-name $sa_name --name ruler --auth-mode login
````

Aktivieren Workload Identity und OIDC issuer
```
az aks update \
  --resource-group $rg\
  --name $clustername \
  --enable-workload-identity \
  --enable-oidc-issuer
```

OIDC issuer URL herausfinden
```
oidc=$(az aks show \
--resource-group $rg \
--name $clustername \
--query "oidcIssuerProfile.issuerUrl" \
-o tsv)
```

Credentials Datei erzeugen
```
cat <<EOF > credentials.json
{
    "name": "LokiFederatedIdentity",
    "issuer": "$oidc",
    "subject": "system:serviceaccount:monitoring:loki",
    "description": "Federated identity for Loki accessing Azure resources",
    "audiences": [
      "api://AzureADTokenExchange"
    ]
}
EOF
```

Entra ID App anlegen
```
 appid=$(az ad app create \
 --display-name $ad_app_name \
 --query appId \
 -o tsv)

 az ad sp create --id $appid

az ad app federated-credential create \
  --id $appid \
  --parameters credentials.json 

az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee $appid \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$rg/providers/Microsoft.Storage/storageAccounts/$sa_name
```

````
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
````

Erstellen von .htpasswd für Basic Authentication
```
htpasswd -c .htpasswd loki
kubectl create secret generic loki-basic-auth --from-file=.htpasswd -n monitoring

kubectl create secret generic canary-basic-auth \
  --from-literal=username=<USERNAME> \
  --from-literal=password=<PASSWORD> \
  -n monitoring
```

Deploy Loki
```
helm upgrade --install --values values.yaml loki grafana/loki -n monitoring 
```
