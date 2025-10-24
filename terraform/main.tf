# Data Sources
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name

  
}

# AKS Cluster Module
module "aks_cluster" {
  source = "./modules/aks-cluster"

  location            = azurerm_resource_group.rg.location
  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  agent_pool_vm_size    = var.agent_pool_vm_size
  agent_pool_node_count = var.agent_pool_node_count
  user_pool_vm_size     = var.user_pool_vm_size
  user_pool_node_count  = var.user_pool_node_count

  admin_group_object_ids       = var.admin_group_object_ids
  rbac_reader_group_object_ids = var.rbac_reader_group_object_ids
  rbac_admin_group_object_ids  = var.rbac_admin_group_object_ids

  local_account_disabled = false

  
}

# Key Vault Module
module "key_vault" {
  source = "./modules/key-vault"

  keyvault_name          = var.keyvault_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  tenant_id              = data.azurerm_client_config.current.tenant_id
  admin_principal_id     = data.azurerm_client_config.current.object_id
  grafana_admin_password = var.SECRET_GRAFANA_ADMIN_PASSWORD
  workload_identity_name = var.workload_identity_name
  oidc_issuer_url        = module.aks_cluster.oidc_issuer_url

  purge_protection_enabled = false # Für Produktion: true

  
}

# Blob Storage Module
module "blob_storage" {
  source = "./modules/blob-storage"

  storage_account_name           = var.STORAGE_ACCOUNT_NAME
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = var.STORAGE_ACCOUNT_LOCATION
  replication_type               = "LRS"
  workload_identity_principal_id = module.key_vault.monitoring_identity_principal_id

  
}

# Bootstrap Module (ArgoCD, Monitoring Setup)
module "bootstrap" {
  source = "./bootstrap"

  aks_cluster_id                = module.aks_cluster.cluster_id
  monitoring_identity_client_id = module.key_vault.monitoring_identity_client_id
  key_vault_name                = module.key_vault.key_vault_name
  key_vault_id                  = module.key_vault.key_vault_id
  tenant_id                     = data.azurerm_client_config.current.tenant_id

  depends_on = [
    module.aks_cluster,
    module.key_vault
  ]
}
