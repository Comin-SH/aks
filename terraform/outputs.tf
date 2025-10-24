# Resource Group Outputs
output "resource_group_name" {
  description = "Name der Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location der Resource Group"
  value       = azurerm_resource_group.rg.location
}

# AKS Cluster Outputs
output "kubernetes_cluster_name" {
  description = "Name des AKS Clusters"
  value       = module.aks_cluster.cluster_name
}

output "kubernetes_cluster_id" {
  description = "ID des AKS Clusters"
  value       = module.aks_cluster.cluster_id
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL für Workload Identity"
  value       = module.aks_cluster.oidc_issuer_url
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name des Key Vaults"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "URI des Key Vaults"
  value       = module.key_vault.key_vault_uri
}

output "monitoring_identity_client_id" {
  description = "Client ID der Monitoring User Assigned Identity für Workload Identity"
  value       = module.key_vault.monitoring_identity_client_id
}

# Storage Account Outputs
output "storage_account_name" {
  description = "Name des Storage Accounts für Loki"
  value       = module.blob_storage.storage_account_name
}

output "storage_account_id" {
  description = "ID des Storage Accounts"
  value       = module.blob_storage.storage_account_id
}

# Kubernetes Config (Sensitive)
output "kube_config" {
  description = "Kubernetes Konfiguration"
  value       = module.aks_cluster.kube_config
  sensitive   = true
}

# Bootstrap Outputs
output "argocd_namespace" {
  description = "Namespace in dem ArgoCD installiert wurde"
  value       = module.bootstrap.argocd_namespace
}

output "argocd_version" {
  description = "Version von ArgoCD"
  value       = module.bootstrap.argocd_version
}
