
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

# Federated Credential: entspricht 2.2. Service Account f�r Loki mit Workload Identity verkn�pfen, entspricht:
# $AKS_OIDC_ISSUER=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)
# $FEDERATED_CREDENTIAL_NAME='monitoring-loki'
# $FEDERATED_CREDENTIAL_SUBJECT='system:serviceaccount:monitoring:loki'
# az identity federated-credential create --name $FEDERATED_CREDENTIAL_NAME --identity-name $WORKLOAD_IDENTITY_NAME --resource-group $RESOURCE_GROUP --issuer $AKS_OIDC_ISSUER --subject $FEDERATED_CREDENTIAL_SUBJECT
resource "azurerm_federated_identity_credential" "loki" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-loki"
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:loki"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_federated_identity_credential" "grafana" {
  resource_group_name = var.resource_group_name
  name                = "monitoring-kube-prometheus-stack-grafana"
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
  subject             = "system:serviceaccount:monitoring:kube-prometheus-stack-grafana"
  audience            = ["api://AzureADTokenExchange"]
}

# User Assigned Identity für Grafana (Workload Identity)
resource "azurerm_user_assigned_identity" "grafana" {
  name                = "grafana-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Key Vault Secrets User Rolle für Grafana Identity
resource "azurerm_role_assignment" "grafana_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.grafana.principal_id
}
