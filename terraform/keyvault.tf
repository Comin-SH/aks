
resource "azurerm_key_vault" "kv" {
  tenant_id           = data.azurerm_client_config.current.tenant_id
  name                = var.keyvault_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "standard"
  # >>> schaltet auf Azure RBAC um (statt Access Policies)
  rbac_authorization_enabled = true
  purge_protection_enabled    = false  # Für Test-Umgebungen
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
  depends_on = [ azurerm_role_assignment.kv_admin_user ]
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "grafana-admin-password" {
  name         = "grafana-admin-password"
  value        = var.SECRET_GRAFANA_ADMIN_PASSWORD
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_role_assignment.kv_admin_user ]
  lifecycle {
    ignore_changes = [value]
  }
}

# User Assigned Identity für Grafana (Workload Identity)
resource "azurerm_user_assigned_identity" "monitoring" {
  name                = "monitoring-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Key Vault Secrets User Rolle für Grafana Identity
resource "azurerm_role_assignment" "grafana_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.monitoring.principal_id
}

# Federated Identity Credential für Loki
resource "azurerm_federated_identity_credential" "loki" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-loki"
  parent_id           = azurerm_user_assigned_identity.monitoring.id
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:loki"
  audience            = ["api://AzureADTokenExchange"]
}

# Federated Identity Credential für Grafana
resource "azurerm_federated_identity_credential" "grafana" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-grafana"
  parent_id           = azurerm_user_assigned_identity.monitoring.id
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:monitoring-grafana"
  audience            = ["api://AzureADTokenExchange"]
}