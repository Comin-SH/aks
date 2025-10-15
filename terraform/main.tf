resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# resource "azuread_group" "aks_admins" {
#   display_name       = var.admin_group_name
#   security_enabled   = true
#   assignable_to_role = true
#   description        = "Admin group for managing the AKS cluster"
# }

resource "azurerm_kubernetes_cluster" "k8s" {
  location               = azurerm_resource_group.rg.location
  name                   = var.cluster_name
  resource_group_name    = azurerm_resource_group.rg.name
  dns_prefix             = var.dns_prefix
  local_account_disabled = true
  identity {
    type = "SystemAssigned"
  }

  # azure_active_directory_role_based_access_control {
  #   admin_group_object_ids = var.admin_group_object_ids
  #   azure_rbac_enabled     = true
  # }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.agent_pool-vm_size
    node_count = var.agent_pool_node_count
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = var.user_pool-vm_size
  node_count            = var.user_pool_node_count
}

resource "azurerm_role_assignment" "admin" {
  for_each = toset(var.admin_group_object_ids)
  scope = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = each.value
}

resource "azurerm_role_assignment" "rbac_reader" {
  for_each = toset(var.rbac_reader_group_object_ids)
  scope = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id = each.value
}