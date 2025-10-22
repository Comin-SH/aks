
resource "azurerm_key_vault" "kv" {
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  name                        = var.keyvault_name
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  sku_name                    = "standard"
  # >>> schaltet auf Azure RBAC um (statt Access Policies)
  rbac_authorization_enabled = true
}

# Angemeldeten Benutzer (aktueller Azure-Account) ermitteln
data "azurerm_client_config" "current" {}

# Rollenzuweisung "Key Vault Administrator" für den aktuellen Benutzer
resource "azurerm_role_assignment" "kv_admin_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "grafana-admin-user" {
  name         = "grafana-admin-user"
  value        = "admin"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "grafana-admin-password" {
  name         = "grafana-admin-password"
  value        = var.SECRET_GRAFANA_ADMIN_PASSWORD
  key_vault_id = azurerm_key_vault.kv.id
}