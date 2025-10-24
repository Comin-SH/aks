# Azure Kubernetes Service (AKS) Infrastructure

Dieses Repository enthält die Infrastructure-as-Code (IaC) Konfiguration für ein Azure Kubernetes Service (AKS) Cluster mit GitOps-basiertem Deployment über ArgoCD.

## 📋 Übersicht

Das Projekt besteht aus zwei Hauptkomponenten:

- **Terraform**: Provisionierung der Azure-Infrastruktur (AKS Cluster, Key Vault, Blob Storage, etc.)
- **ArgoCD**: Deklaratives GitOps-basiertes Deployment von Kubernetes-Applikationen

## 🏗️ Architektur

```
┌─────────────────────────────────────────────────────────────┐
│                      Azure Cloud                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  AKS Cluster (Kubernetes)                              │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │ │
│  │  │  ArgoCD  │  │ Grafana/ │  │Nextcloud │            │ │
│  │  │          │  │   Loki   │  │          │            │ │
│  │  └──────────┘  └──────────┘  └──────────┘            │ │
│  │         │             │              │                 │ │
│  └─────────┼─────────────┼──────────────┼─────────────────┘ │
│            │             │              │                   │
│    ┌───────▼───────┐ ┌──▼──────────┐ ┌─▼──────────┐       │
│    │  Key Vault    │ │Blob Storage │ │ Azure AD   │       │
│    │  (Secrets)    │ │   (Loki)    │ │   (RBAC)   │       │
│    └───────────────┘ └─────────────┘ └────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Komponenten

- **AKS Cluster**: Managed Kubernetes Service mit System- und User-Node-Pools
- **Azure AD Integration**: RBAC-basierte Zugriffskontrolle mit Entra ID Gruppen
- **Workload Identity**: Sichere Service-to-Service Authentifizierung
- **Key Vault**: Secrets Management für Grafana Admin-Credentials
- **Blob Storage**: Persistente Speicherung für Loki Logs
- **ArgoCD**: GitOps-Operator für automatisiertes Deployment
- **Monitoring Stack**: Prometheus, Grafana, Loki für Observability
- **Nextcloud**: Collaborative Cloud Storage

## 🚀 Quick Start

### Voraussetzungen

Stelle sicher, dass folgende Tools installiert sind:

```bash
# Prüfen der installierten Versionen
az --version          # Azure CLI
terraform --version   # Terraform >= 1.8.0
kubectl version       # Kubernetes CLI
kubelogin --version   # Azure AD Plugin für kubectl
helm version          # Helm >= 3.0
```

Installation fehlender Tools:
```bash
# Azure CLI
brew install azure-cli

# Terraform
brew install terraform

# kubectl und kubelogin
az aks install-cli

# Helm
brew install helm

# ArgoCD CLI (optional)
brew install argocd
```

### 1. Azure Login

```bash
az login
az account show  # Korrekte Subscription prüfen
az account set --subscription "<subscription-id>"  # Falls notwendig
```

### 2. Terraform Backend einrichten

Erstelle einen Azure Storage Account für den Terraform State (einmalig):

```bash
#!/bin/bash
RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate

# Resource Group erstellen
az group create --name $RESOURCE_GROUP_NAME --location germanywestcentral

# Storage Account erstellen
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Blob Container erstellen
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME

# Access Key exportieren
export ARM_ACCESS_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' -o tsv)
```

Aktualisiere `terraform/providers.tf` mit dem Storage Account Namen.

### 3. Terraform Konfiguration

```bash
cd terraform

# Kopiere das Beispiel und passe die Werte an
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Anpassen der Variablen

# Initialisierung
terraform init -upgrade

# Plan anzeigen
terraform plan

# Infrastruktur erstellen
terraform apply
```

### 4. Kubernetes Zugriff konfigurieren

```bash
# Kubeconfig automatisch erstellen
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw kubernetes_cluster_name)

# Verbindung testen
kubectl get nodes
```

### 5. ArgoCD installieren

Siehe detaillierte Anleitung in [`argocd/README.md`](./argocd/README.md)

```bash
cd ../argocd

# Helm Repository hinzufügen
helm repo add argo https://argoproj.github.io/argo-helm

# ArgoCD installieren
helm install argocd argo/argo-cd -n argocd --create-namespace

# Initiales Admin-Passwort abrufen
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

# Port-Forwarding für Zugriff
kubectl port-forward svc/argocd-server -n argocd 8080:https
```

Öffne https://localhost:8080 und logge dich mit `admin` und dem abgerufenen Passwort ein.

## 📁 Repository-Struktur

```
.
├── README.md                    # Diese Datei
├── .gitignore                   # Git Ignore Regeln
├── terraform/                   # Terraform IaC
│   ├── README.md               # Terraform-spezifische Dokumentation
│   ├── main.tf                 # AKS Cluster Definition
│   ├── variables.tf            # Input Variablen
│   ├── outputs.tf              # Output Werte
│   ├── providers.tf            # Provider Konfiguration
│   ├── argocd.tf              # ArgoCD Ressourcen
│   ├── blobstorage.tf         # Blob Storage für Loki
│   ├── grafana.tf             # Grafana Key Vault Integration
│   ├── keyvault.tf            # Azure Key Vault
│   ├── terraform.tfvars.example  # Beispiel-Konfiguration
│   └── modules/                # Wiederverwendbare Terraform Module
│       ├── aks-cluster/        # AKS Cluster Modul
│       ├── key-vault/          # Key Vault Modul
│       └── blob-storage/       # Blob Storage Modul
└── argocd/                     # ArgoCD Apps & Config
    ├── README.md               # ArgoCD Dokumentation
    ├── bootstrap/              # Bootstrap-Ressourcen
    │   ├── apps-of-apps.yaml  # Apps of Apps Pattern
    │   └── repository.yaml    # Git Repository Secret
    ├── applications/           # Application Definitions
    │   ├── argocd-application.yaml
    │   ├── monitoring-application.yaml
    │   ├── nextcloud-application.yaml
    │   └── monitoring/        # Monitoring Stack Values
    │       ├── kube-prometheus-stack/
    │       └── loki/
    └── values/                # Shared Values
        └── common.yaml        # Gemeinsame Konfiguration
            └── ...
```

## 🔐 Sicherheit & RBAC

### Azure AD Integration

Das Cluster verwendet Azure AD für Authentifizierung und RBAC:

- **Admin Groups**: Volle Cluster-Admin-Rechte
- **Reader Groups**: Lesezugriff auf Kubernetes-Ressourcen

Konfiguration in `terraform.tfvars`:
```hcl
admin_group_object_ids       = ["<object-id>"]
rbac_reader_group_object_ids = ["<object-id>"]
rbac_admin_group_object_ids  = ["<object-id>"]
```

### Workload Identity

Kubernetes Pods authentifizieren sich gegenüber Azure Services über Workload Identity:

- **Grafana**: Zugriff auf Key Vault für Admin-Passwort
- **Loki**: Zugriff auf Blob Storage für Log-Persistierung

### Secrets Management

- Sensible Daten werden in **Azure Key Vault** gespeichert
- **CSI Secrets Store Driver** macht Secrets als Volumes verfügbar
- **Niemals** Secrets in Git committen

## 🔧 Wartung & Updates

### Terraform State

Der Terraform State wird sicher in Azure Blob Storage gespeichert:
- **Versionierung**: Änderungshistorie nachvollziehbar
- **Locking**: Verhindert parallele Ausführung
- **Verschlüsselung**: Automatische Verschlüsselung at-rest

### ArgoCD Updates

ArgoCD verwaltet sich selbst und kann über Git aktualisiert werden. **Nicht** über Terraform updaten, um State-Drift zu vermeiden.

### Cluster Updates

```bash
# Verfügbare Kubernetes-Versionen anzeigen
az aks get-upgrades \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw kubernetes_cluster_name)

# Upgrade über Terraform durchführen
# In main.tf die kubernetes_version anpassen und apply
```

## 📊 Monitoring & Observability

### Zugriff auf Grafana

```bash
# Port-Forward zu Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Admin-Passwort aus Key Vault
# (wird automatisch als Secret in den Pod gemountet)
```

Öffne http://localhost:3000

### Loki Logs

Logs werden automatisch von allen Pods gesammelt und in Azure Blob Storage persistiert.

## 🗑️ Cleanup

```bash
# Alle Ressourcen löschen
cd terraform
terraform destroy

# Cluster aus kubeconfig entfernen
kubectl config delete-cluster <cluster-name>

# Optional: Terraform State Storage Account löschen
az group delete --name tfstate --yes
```

## 📚 Weitere Dokumentation

- [Terraform Details](./terraform/README.md)
- [Terraform Module](./terraform/modules/README.md)
- [ArgoCD Setup](./argocd/README.md)
- [Monitoring Setup](./argocd/applications/monitoring/README.md)
- [Grafana Configuration](./argocd/applications/monitoring/kube-prometheus-stack/README.md)
- [Loki Setup](./argocd/applications/monitoring/loki/README.md)

## 🤝 Beitragende

### Branching Strategy

- `main`: Produktions-Branch (geschützt)
- `feature/*`: Feature-Entwicklung
- `fix/*`: Bugfixes

### Pull Request Workflow

1. Feature-Branch erstellen
2. Änderungen committen
3. Pull Request erstellen
4. Review abwarten
5. Merge nach `main`

## ⚠️ Wichtige Hinweise

- ✅ **Niemals** `terraform.tfstate` in Git committen
- ✅ **Niemals** `terraform.tfvars` in Git committen (enthält Secrets)
- ✅ Verwende `terraform.tfvars.example` als Template
- ✅ Backend-Konfiguration vor dem ersten `terraform init` anpassen
- ✅ Teste Changes immer erst mit `terraform plan`

## 📞 Support & Troubleshooting

### Häufige Probleme

**Problem**: `Error: Unauthorized`
```bash
# Lösung: Kubelogin zurücksetzen
az aks get-credentials --resource-group <rg> --name <cluster> --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
```

**Problem**: Terraform Backend-Fehler
```bash
# Lösung: Access Key neu exportieren
export ARM_ACCESS_KEY=$(az storage account keys list \
  --resource-group tfstate \
  --account-name <storage-account> \
  --query '[0].value' -o tsv)
```

## 📜 Lizenz

[Lizenz-Information hier einfügen]

## 🔗 Referenzen

- [Azure AKS Dokumentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kube-Prometheus-Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
