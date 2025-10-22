# Workload Identity (User Assigned Managed Identity)
resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = var.workload_identity_name
  location            = var.STORAGE_ACCOUNT_LOCATION
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_storage_account" "loki" {
  name                     = var.STORAGE_ACCOUNT_NAME
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.STORAGE_ACCOUNT_LOCATION
  account_tier             = "Standard"
  account_replication_type = "LRS"
  }


# Rolle "Storage Blob Data Contributor" auf Storage-Account-Ebene zuweisen
resource "azurerm_role_assignment" "wi_blob_contrib" {
  scope                = azurerm_storage_account.loki.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
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