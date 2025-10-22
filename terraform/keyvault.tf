
resource "azurerm_key_vault" "kv" {
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  name                        = var.keyvault_name
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  sku_name                    = "standard"
}

# Angemeldeten Benutzer (aktueller Azure-Account) ermitteln
data "azurerm_client_config" "current" {}

# Bestehenden Key Vault referenzieren
data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

# Rollenzuweisung "Key Vault Administrator" für den aktuellen Benutzer
resource "azurerm_role_assignment" "kv_admin_user" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
