# Key Vault Module

Dieses Terraform-Modul erstellt einen Azure Key Vault mit Secrets für Grafana und einer User Assigned Managed Identity (Workload Identity) für Monitoring-Komponenten.

## Features

- ✅ Azure Key Vault mit RBAC-basierter Zugriffskontrolle
- ✅ Grafana Admin Credentials als Secrets
- ✅ User Assigned Managed Identity für Monitoring
- ✅ Federated Identity Credentials für Grafana & Loki
- ✅ Automatische Rollenzuweisungen

## Verwendung

```hcl
module "key_vault" {
  source = "./modules/key-vault"

  keyvault_name       = "myaks-kv-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_principal_id  = data.azurerm_client_config.current.object_id

  grafana_admin_password  = var.SECRET_GRAFANA_ADMIN_PASSWORD
  workload_identity_name  = "monitoring-identity"
  oidc_issuer_url         = module.aks_cluster.oidc_issuer_url

  purge_protection_enabled = false  # Für Prod: true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Beschreibung | Typ | Default | Required |
|------|--------------|-----|---------|----------|
| keyvault_name | Name des Key Vaults | `string` | - | yes |
| resource_group_name | Name der Resource Group | `string` | - | yes |
| location | Azure Region | `string` | - | yes |
| tenant_id | Azure AD Tenant ID | `string` | - | yes |
| admin_principal_id | Principal ID des Administrators | `string` | - | yes |
| grafana_admin_password | Admin Passwort für Grafana | `string` (sensitive) | - | yes |
| workload_identity_name | Name der Workload Identity | `string` | - | yes |
| oidc_issuer_url | OIDC Issuer URL vom AKS Cluster | `string` | - | yes |
| purge_protection_enabled | Purge Protection aktivieren | `bool` | `false` | no |
| tags | Resource Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Beschreibung |
|------|--------------|
| key_vault_id | Die ID des Key Vaults |
| key_vault_name | Der Name des Key Vaults |
| key_vault_uri | Die URI des Key Vaults |
| monitoring_identity_id | ID der Monitoring Identity |
| monitoring_identity_client_id | Client ID der Monitoring Identity |
| monitoring_identity_principal_id | Principal ID der Monitoring Identity |

## Secrets

Das Modul erstellt automatisch folgende Secrets:

- **grafana-admin-user**: Grafana Admin Benutzername (default: `admin`)
- **grafana-admin-password**: Grafana Admin Passwort (aus Variable)

## Workload Identity

Die User Assigned Managed Identity erhält automatisch:

- **Key Vault Secrets User** Rolle auf dem Key Vault
- **Federated Identity Credential** für `system:serviceaccount:monitoring:monitoring-grafana`
- **Federated Identity Credential** für `system:serviceaccount:monitoring:loki`

## Beispiel

Vollständiges Beispiel mit AKS Cluster Integration:

```hcl
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "germanywestcentral"
}

module "aks_cluster" {
  source = "./modules/aks-cluster"
  # ... AKS Konfiguration
}

module "key_vault" {
  source = "./modules/key-vault"

  keyvault_name       = "myakskv${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_principal_id  = data.azurerm_client_config.current.object_id

  grafana_admin_password  = var.grafana_password
  workload_identity_name  = "monitoring-wi"
  oidc_issuer_url         = module.aks_cluster.oidc_issuer_url

  purge_protection_enabled = true

  tags = {
    Environment = "Production"
  }
}

# Verwende die Outputs in der Grafana Konfiguration
output "grafana_identity_client_id" {
  value = module.key_vault.monitoring_identity_client_id
}
```

## Hinweise

- ✅ Key Vault Name muss global eindeutig sein (3-24 Zeichen)
- ✅ Purge Protection sollte in Produktion aktiviert sein
- ✅ Secrets verwenden `ignore_changes` im Lifecycle, um manuelle Änderungen zu erlauben
- ✅ Federated Identity Credentials ermöglichen Kubernetes Pods den Zugriff ohne Secrets
- ⚠️ Workload Identity benötigt aktivierten OIDC Issuer im AKS Cluster
