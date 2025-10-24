# Terraform Infrastructure für AKS

Diese Terraform-Konfiguration erstellt die komplette Azure-Infrastruktur für ein produktionsreifes AKS-Cluster.

## 📦 Module

Die Infrastruktur ist in wiederverwendbare Module aufgeteilt:

- **[aks-cluster](./modules/aks-cluster/)**: AKS Cluster mit Node Pools und RBAC
- **[key-vault](./modules/key-vault/)**: Key Vault, Secrets und Workload Identity  
- **[blob-storage](./modules/blob-storage/)**: Storage Account für Loki Logs

Siehe [modules/README.md](./modules/README.md) für Details.

> ℹ️ **Hinweis**: Die aktuelle Implementierung verwendet noch keine Module. Siehe [MIGRATION.md](./MIGRATION.md) für den Migrations-Guide.

## Voraussetzung
- Terraform >= 1.8.0 installiert
- Azure CLI installiert
- kubectl installiert
- kubelogin installiert

Die letzten beiden Punkte können mit folgendem Code installiert werden:
```bash
az aks install-cli
```

### Vorbereitung
- Github Repo herunterladen
- Notwendige Anpassungen NUR in terraform.tfvars durchführen, Default Werte sieht man in variables.tf
- admin_group_object_ids und rbac_reader_group_object_ids können mit der Object ID von Entra ID Gruppen befüllt werden, so dass Mitglieder dieser Gruppe entsprechend lesenden oder administrativen Zugriff auf das Kubernetes Cluster bekommen

### Speichern des Terraform States in einem Azure Storage Account
Terraform benötigt eine zentrale Datei (terraform.tfstate), in der der tatsächliche Zustand deiner Infrastruktur liegt.
Diese Datei sollte niemals lokal oder im Git-Repo gespeichert werden, sondern in einem Remote Backend, das folgende Eigenschaften hat:

- Versionskontrolle (wer hat wann was geändert)
- Locking (damit keine zwei Nutzer gleichzeitig „apply“ ausführen)
- Zugriffskontrolle (RBAC)
- Sicheres Backup

⚠️ Warum du den Terraform-State nicht im Git speichern solltest
1️⃣ Der State enthält geheime Daten (Secrets, Keys, Passwörter)
Der Terraform-State speichert nicht nur Ressourcen-IDs, sondern den kompletten aktuellen Zustand — inklusive aller Attribute, die Terraform über deine Infrastruktur kennt.
In Blob Storage wird alles automatisch verschlüsselt und gelockt, wenn jemand terraform apply ausführt.

Quelle: https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
Der Blob-Storage wird manuell vorab erstellt. In Zukunft wäre es möglich dies ebenfalls über ein eigenes Terraform Deployment durchzuführen.

## Notwendige Schritte:
```
#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=cidevttfstate$RANDOM
CONTAINER_NAME=tfstate$

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location germanywestcentral

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Configure terraform backend state
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```
Folgende Informationen müssen dann in providers.tf gepflegt werden:
```
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "<storage_account_name>"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
```


### Schritte
1. Als erstes Mittels "az login" anmelden und korrekte Subscription auswählen. Mit dem zweiten Befehl kann geprüft werden, ob korrekte Subscription ausgewählt ist.

<code>
az login

az account show
</code>

2. Führen Sie zum Initialisieren der Terraform-Bereitstellung terraform init aus. Mit diesem Befehl wird der Azure-Anbieter heruntergeladen, der zum Verwalten Ihrer Azure-Ressourcen erforderlich ist.

`terraform init -upgrade` 

3. Anzeigen was Terraform tun wird.

`terraform plan`

4. Ausführen der Bereitstellung

`terraform apply`

5. Kubeconfig erzeugen, wird automatisch mit bestehender config zusammengeführt

`az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

6. Azure Kubernetes Ressource im Azure Portal öffnen (optional)

`az aks browse --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

7. Löschen der Bereitstellung

`terraform destroy`

8. Löschen von Cluster aus kubeconfig

`kubectl config delete-cluster <clustername>`



Quellen:
https://learn.microsoft.com/de-de/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli --> hier wurden alle random (Pet) Variablen durch statische Variablen ersetzt.

https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks

Details zu Azure RBAC: https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac?tabs=azure-cli



## Installation von Argo CD
Es wird zu diesem Stand darauf verzichtet Argo CD mittels Terraform bereitzustellen, stattdessen wird dieser Schritt einmalig manuell für das Cluster ausgeführt

Begründung:
- bei der Bereitstellung mittels Terraform müsste auch Updates für Argo CD mittels Terraform durchgeführt werden, dies wird als unpraktisch bewertet
- eine Aktualisierung von ArgoCD nachträglich über andere Mittel, würde zu einem Versionsunterschied zwischen Terraform und Realität führen
- bei einer manuellen Installation von ArgoCD kann sich dies nach der Bereitstellung selbst aktualisieren und verwalten

**Weitere Schritte im Ordner argocd**

## Variablen können in einer terraform.tfvars angegeben werden, diese werden aber nicht mittels Git synchronisiert, da sie sensitive Dateien enthalten können
# Beispiel
```
# resource_group_location = "germanywestcentral"
# resource_group_name     = "k8s-rg"
# agent_pool_node_count   = 1
# agent_pool_vm_size      = "Standard_D2as_v5"
# user_pool_vm_size       = "Standard_D2as_v5"
# user_pool_node_count    = 1
# cluster_name            = "k8s"
# dns_prefix              = "k8s"
# admin_group_object_ids  = []
# rbac_reader_group_object_ids = []
# rbac_admin_group_object_ids  = []

# subscription_id = ""

# STORAGE_ACCOUNT_NAME     = ""
# STORAGE_ACCOUNT_LOCATION = "germanywestcentral"
# workload_identity_name   = ""
# keyvault_name            = ""
# SECRET_GRAFANA_ADMIN_PASSWORD = ""
```

Hinweis: Speichere deine produktive Konfiguration als `terraform.tfvars` (wird durch `.gitignore` ausgeschlossen) oder übergib sie per `-var-file`.
