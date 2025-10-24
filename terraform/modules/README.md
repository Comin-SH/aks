# Terraform Modules

Dieser Ordner enthält wiederverwendbare Terraform-Module für die AKS-Infrastruktur.

## Verfügbare Module

### 1. [aks-cluster](./aks-cluster/)
Erstellt einen Azure Kubernetes Service Cluster mit:
- System und User Node Pools
- Azure AD RBAC Integration
- Workload Identity Support
- Blob Storage Driver
- Key Vault CSI Driver

### 2. [key-vault](./key-vault/)
Erstellt einen Azure Key Vault mit:
- Grafana Admin Credentials
- Workload Identity (User Assigned Managed Identity)
- Federated Identity Credentials für Grafana & Loki
- RBAC-basierte Zugriffskontrolle

### 3. [blob-storage](./blob-storage/)
Erstellt einen Azure Storage Account mit:
- Blob Container für Loki Logs (chunks & ruler)
- RBAC Rollenzuweisung für Workload Identity
- Konfigurierbare Replikation

## Verwendung

Siehe das Haupt-`main.tf` für die Verwendung dieser Module:

```hcl
# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# AKS Cluster Modul
module "aks_cluster" {
  source = "./modules/aks-cluster"

  location            = azurerm_resource_group.rg.location
  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  agent_pool_vm_size    = var.agent_pool_vm_size
  agent_pool_node_count = var.agent_pool_node_count
  user_pool_vm_size     = var.user_pool_vm_size
  user_pool_node_count  = var.user_pool_node_count

  admin_group_object_ids       = var.admin_group_object_ids
  rbac_reader_group_object_ids = var.rbac_reader_group_object_ids
  rbac_admin_group_object_ids  = var.rbac_admin_group_object_ids

  
}

# Key Vault Modul
module "key_vault" {
  source = "./modules/key-vault"

  keyvault_name          = var.keyvault_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  tenant_id              = data.azurerm_client_config.current.tenant_id
  admin_principal_id     = data.azurerm_client_config.current.object_id
  grafana_admin_password = var.SECRET_GRAFANA_ADMIN_PASSWORD
  workload_identity_name = var.workload_identity_name
  oidc_issuer_url        = module.aks_cluster.oidc_issuer_url

  
}

# Blob Storage Modul
module "blob_storage" {
  source = "./modules/blob-storage"

  storage_account_name           = var.STORAGE_ACCOUNT_NAME
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = var.STORAGE_ACCOUNT_LOCATION
  workload_identity_principal_id = module.key_vault.monitoring_identity_principal_id

  
}
```

## Best Practices

### Module Versioning
Für Produktionsumgebungen sollten Module versioniert werden:

```hcl
module "aks_cluster" {
  source = "git::https://github.com/your-org/terraform-modules.git//aks-cluster?ref=v1.0.0"
  # ...
}
```

### Abhängigkeiten
Module haben folgende Abhängigkeiten:

```
aks-cluster (standalone)
    ↓
key-vault (benötigt: oidc_issuer_url von aks-cluster)
    ↓
blob-storage (benötigt: monitoring_identity_principal_id von key-vault)
```

### Testing
Teste Module lokal mit:

```bash
cd modules/aks-cluster
terraform init
terraform validate
terraform fmt -check
```

## Migration

Wenn du von der alten Struktur (ohne Module) migrierst:

1. **Backup erstellen**: `terraform state pull > backup.tfstate`
2. **State verschieben**: 
   ```bash
   terraform state mv azurerm_kubernetes_cluster.k8s module.aks_cluster.azurerm_kubernetes_cluster.k8s
   terraform state mv azurerm_key_vault.kv module.key_vault.azurerm_key_vault.kv
   # ... etc
   ```
3. **Plan prüfen**: `terraform plan` sollte keine Änderungen zeigen

## Weitere Ressourcen

- [Terraform Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
