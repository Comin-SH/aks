# Blob Storage Module

Dieses Terraform-Modul erstellt einen Azure Storage Account mit Blob Containern für Loki Log-Persistierung.

## Features

- ✅ Azure Storage Account mit konfigurierter Replikation
- ✅ Zwei Blob Container (chunks & ruler) für Loki
- ✅ RBAC-basierte Zugriffskontrolle
- ✅ Storage Blob Data Contributor Rolle für Workload Identity
- ✅ Validation für Storage Account Namen

## Verwendung

```hcl
module "blob_storage" {
  source = "./modules/blob-storage"

  storage_account_name           = "mylokistorage${random_string.suffix.result}"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  replication_type               = "LRS"
  workload_identity_principal_id = module.key_vault.monitoring_identity_principal_id

  tags = {
    Environment = "Production"
    Purpose     = "Loki-Logs"
  }
}
```

## Inputs

| Name | Beschreibung | Typ | Default | Required |
|------|--------------|-----|---------|----------|
| storage_account_name | Name des Storage Accounts (global eindeutig, 3-24 Zeichen, nur Kleinbuchstaben und Zahlen) | `string` | - | yes |
| resource_group_name | Name der Resource Group | `string` | - | yes |
| location | Azure Region | `string` | - | yes |
| replication_type | Replikationstyp (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS) | `string` | `"LRS"` | no |
| workload_identity_principal_id | Principal ID der Workload Identity | `string` | - | yes |
| tags | Resource Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Beschreibung |
|------|--------------|
| storage_account_id | Die ID des Storage Accounts |
| storage_account_name | Der Name des Storage Accounts |
| primary_blob_endpoint | Der primäre Blob Endpoint |
| chunks_container_name | Name des Chunks Containers |
| ruler_container_name | Name des Ruler Containers |

## Container

Das Modul erstellt automatisch zwei Container:

- **chunks**: Speichert Loki Log Chunks
- **ruler**: Speichert Loki Ruler Daten

Beide Container sind auf `private` gesetzt.

## Replikationstypen

| Typ | Beschreibung | Verfügbarkeit |
|-----|--------------|---------------|
| LRS | Locally Redundant Storage | 99.999999999% (11 9's) |
| ZRS | Zone Redundant Storage | 99.9999999999% (12 9's) |
| GRS | Geo Redundant Storage | 99.99999999999999% (16 9's) |
| GZRS | Geo-Zone Redundant Storage | 99.99999999999999% (16 9's) |

## Beispiel

Vollständiges Beispiel mit Key Vault Integration:

```hcl
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = "my-rg"
  location = "germanywestcentral"
}

module "key_vault" {
  source = "./modules/key-vault"
  # ... Key Vault Konfiguration
}

module "blob_storage" {
  source = "./modules/blob-storage"

  storage_account_name           = "loki${random_string.storage_suffix.result}"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  replication_type               = "GRS"  # Geo-Redundant für Produktion
  workload_identity_principal_id = module.key_vault.monitoring_identity_principal_id

  tags = {
    Environment = "Production"
    Application = "Loki"
    ManagedBy   = "Terraform"
  }
}

# Verwende die Outputs in der Loki Konfiguration
output "loki_storage_account" {
  value = module.blob_storage.storage_account_name
}
```

## Loki Konfiguration

Verwende die Module-Outputs in deiner Loki `values.yaml`:

```yaml
loki:
  storage:
    type: azure
    azure:
      accountName: ${storage_account_name}
      accountKey: ""  # Nicht benötigt mit Workload Identity
      container: chunks
      useManagedIdentity: true
```

## Hinweise

- ⚠️ Storage Account Name muss **global eindeutig** sein
- ⚠️ Nur Kleinbuchstaben und Zahlen (3-24 Zeichen)
- ✅ Das Modul enthält Validation für den Namen
- ✅ Workload Identity benötigt **Storage Blob Data Contributor** Rolle
- ✅ Für Produktion empfiehlt sich **GRS** oder **GZRS** Replikation
- ✅ Access Keys werden nicht benötigt (Workload Identity via RBAC)

## Kosten

Storage-Kosten basieren auf:
- Gespeicherte Datenmenge (GB/Monat)
- Anzahl der Transaktionen (Read/Write Operations)
- Replikationstyp (GRS ~2x teurer als LRS)

Für Loki Logs empfiehlt sich:
- **Hot Tier**: Für aktuelle Logs (letzte 7-30 Tage)
- **Cool/Archive Tier**: Für ältere Logs (Lifecycle Policy)
