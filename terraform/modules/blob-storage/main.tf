resource "azurerm_storage_account" "loki" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  tags = var.tags
}

# Rolle "Storage Blob Data Contributor" auf Storage-Account-Ebene zuweisen
resource "azurerm_role_assignment" "workload_identity_blob_contrib" {
  scope                = azurerm_storage_account.loki.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.workload_identity_principal_id
}

resource "azurerm_storage_container" "chunks" {
  name                  = "chunks"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "ruler" {
  name                  = "ruler"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}
