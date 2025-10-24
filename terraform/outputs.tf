output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "monitoring_identity_client_id" {
  value       = azurerm_user_assigned_identity.monitoring.client_id
  description = "Client ID der Monitoring User Assigned Identity für Workload Identity"
}