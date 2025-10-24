resource "azurerm_key_vault" "kv" {
  tenant_id                  = var.tenant_id
  name                       = var.keyvault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = var.purge_protection_enabled

  tags = var.tags
}

resource "azurerm_role_assignment" "kv_admin_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_principal_id
}

resource "azurerm_key_vault_secret" "grafana_admin_user" {
  name         = "grafana-admin-user"
  value        = "admin"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_admin_user]
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  value        = var.grafana_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_admin_user]
  lifecycle {
    ignore_changes = [value]
  }
}

# User Assigned Identity für Monitoring (Grafana & Loki)
resource "azurerm_user_assigned_identity" "monitoring" {
  name                = var.workload_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# Key Vault Secrets User Rolle für Monitoring Identity
resource "azurerm_role_assignment" "monitoring_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.monitoring.principal_id
}

# Federated Identity Credential für Loki
resource "azurerm_federated_identity_credential" "loki" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-loki"
  parent_id           = azurerm_user_assigned_identity.monitoring.id
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:loki"
  audience            = ["api://AzureADTokenExchange"]
}

# Federated Identity Credential für Grafana
resource "azurerm_federated_identity_credential" "grafana" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-grafana"
  parent_id           = azurerm_user_assigned_identity.monitoring.id
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:monitoring-grafana"
  audience            = ["api://AzureADTokenExchange"]
}
