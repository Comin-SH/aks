# AKS Cluster Module

Dieses Terraform-Modul erstellt einen Azure Kubernetes Service (AKS) Cluster mit zwei Node-Pools (System und User) und konfigurierten RBAC-Berechtigungen.

## Features

- ✅ AKS Cluster mit Azure AD Integration
- ✅ System Node Pool (agentpool) für System-Workloads
- ✅ User Node Pool (userpool) für Anwendungs-Workloads
- ✅ Workload Identity & OIDC Issuer aktiviert
- ✅ Blob Storage Driver für persistente Volumes
- ✅ Key Vault Secrets Provider (CSI Driver)
- ✅ RBAC Rollen-Zuweisungen (Reader & Admin)

## Verwendung

```hcl
module "aks_cluster" {
  source = "./modules/aks-cluster"

  location            = "germanywestcentral"
  cluster_name        = "my-aks-cluster"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  # Node Pool Konfiguration
  agent_pool_vm_size    = "Standard_D2as_v5"
  agent_pool_node_count = 2
  user_pool_vm_size     = "Standard_D4as_v5"
  user_pool_node_count  = 3

  # RBAC Konfiguration
  admin_group_object_ids       = ["<entra-id-group-object-id>"]
  rbac_reader_group_object_ids = ["<entra-id-group-object-id>"]
  rbac_admin_group_object_ids  = ["<entra-id-group-object-id>"]

  # Optionale Einstellungen
  local_account_disabled = false

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Beschreibung | Typ | Default | Required |
|------|--------------|-----|---------|----------|
| location | Azure Region | `string` | - | yes |
| cluster_name | Name des AKS Clusters | `string` | - | yes |
| resource_group_name | Name der Resource Group | `string` | - | yes |
| dns_prefix | DNS Präfix | `string` | - | yes |
| agent_pool_vm_size | VM Größe für System Pool | `string` | `"Standard_D2as_v5"` | no |
| agent_pool_node_count | Anzahl Nodes im System Pool | `number` | `1` | no |
| user_pool_vm_size | VM Größe für User Pool | `string` | `"Standard_D2as_v5"` | no |
| user_pool_node_count | Anzahl Nodes im User Pool | `number` | `1` | no |
| admin_group_object_ids | Admin Gruppen (Object IDs) | `list(string)` | `[]` | no |
| rbac_reader_group_object_ids | Reader Gruppen | `list(string)` | `[]` | no |
| rbac_admin_group_object_ids | RBAC Admin Gruppen | `list(string)` | `[]` | no |
| local_account_disabled | Lokale Accounts deaktivieren | `bool` | `false` | no |
| tags | Resource Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Beschreibung |
|------|--------------|
| cluster_id | Die ID des AKS Clusters |
| cluster_name | Der Name des AKS Clusters |
| oidc_issuer_url | OIDC Issuer URL für Workload Identity |
| kube_config | Kubernetes Konfiguration (sensitive) |
| kube_admin_config | Admin Kubernetes Konfiguration (sensitive) |
| host | Kubernetes API Server Host (sensitive) |
| client_certificate | Client Zertifikat (sensitive) |
| client_key | Client Key (sensitive) |
| cluster_ca_certificate | Cluster CA Zertifikat (sensitive) |

## Beispiel

Vollständiges Beispiel mit allen abhängigen Ressourcen:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "germanywestcentral"
}

module "aks_cluster" {
  source = "./modules/aks-cluster"

  location            = azurerm_resource_group.rg.location
  cluster_name        = "production-aks"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "prodaks"

  agent_pool_node_count = 2
  user_pool_node_count  = 3

  admin_group_object_ids = [
    "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  ]

  tags = {
    Environment = "Production"
    Team        = "Platform"
  }
}

output "cluster_name" {
  value = module.aks_cluster.cluster_name
}
```

## Hinweise

- Der System Node Pool (`agentpool`) sollte für Kubernetes System-Komponenten reserviert sein
- Der User Node Pool (`userpool`) wird für Anwendungs-Workloads verwendet
- `temporary_name_for_rotation` ermöglicht Node Pool Upgrades ohne Downtime
- OIDC Issuer ist für Workload Identity erforderlich
- Blob Driver wird für Loki Log-Storage benötigt
