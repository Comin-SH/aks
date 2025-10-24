output "cluster_id" {
  description = "The Kubernetes Cluster ID"
  value       = azurerm_kubernetes_cluster.k8s.id
}

output "cluster_name" {
  description = "The Kubernetes Cluster name"
  value       = azurerm_kubernetes_cluster.k8s.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Kubernetes admin configuration"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity"
  value       = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
}

output "kubelet_identity" {
  description = "The Kubelet Identity"
  value       = azurerm_kubernetes_cluster.k8s.kubelet_identity
}

output "host" {
  description = "Kubernetes API server host"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Kubernetes client certificate"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Kubernetes client key"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = azurerm_kubernetes_cluster.k8s.kube_admin_config[0].cluster_ca_certificate
  sensitive   = true
}
