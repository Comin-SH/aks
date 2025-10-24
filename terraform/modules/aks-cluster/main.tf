resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.location
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  # Lokaler Account erstmal aktiviert, damit Argo CD mittels Helm installiert werden kann
  local_account_disabled = var.local_account_disabled

  # Die Workload Identity wird später von Grafana für den Zugriff auf den Key Vault und von Loki für den Zugriff auf den Blob Storage benötigt.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Wird benötigt als Storage für Loki
  storage_profile {
    blob_driver_enabled = true
  }

  key_vault_secrets_provider {
    # Default-Wert gem. Dokumentation --> https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-configuration-options
    secret_rotation_interval = "2m"
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  default_node_pool {
    name                        = "agentpool"
    vm_size                     = var.agent_pool_vm_size
    node_count                  = var.agent_pool_node_count
    temporary_name_for_rotation = "agentpooltmp" # Nur für Rotation
    upgrade_settings {
      # Wert gesetzt, damit er nicht bei jedem terraform apply das Cluster verändern will. Weitere Infos: https://github.com/hashicorp/terraform-provider-azurerm/issues/24020
      max_surge = "10%"
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                        = "userpool"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.k8s.id
  vm_size                     = var.user_pool_vm_size
  node_count                  = var.user_pool_node_count
  temporary_name_for_rotation = "userpooltmp" # Nur für Rotation
  upgrade_settings {
    # Wert gesetzt, damit er nicht bei jedem terraform apply das Cluster verändern will. Weitere Infos: https://github.com/hashicorp/terraform-provider-azurerm/issues/24020
    max_surge = "10%"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "cluster_user" {
  for_each             = toset(local.all_aks_users)
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "rbac_reader" {
  for_each             = toset(var.rbac_reader_group_object_ids)
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "admin" {
  for_each             = toset(var.rbac_admin_group_object_ids)
  scope                = azurerm_kubernetes_cluster.k8s.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}

locals {
  all_aks_users = setunion(var.rbac_reader_group_object_ids, var.rbac_admin_group_object_ids)
}
