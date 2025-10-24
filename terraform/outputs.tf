output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "grafana_identity_client_id" {
  value       = azurerm_user_assigned_identity.grafana.client_id
  description = "Client ID der Grafana User Assigned Identity für Workload Identity"
}