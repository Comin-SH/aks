# Variables für Bootstrap-Module

variable "aks_cluster_id" {
  description = "ID des AKS Clusters"
  type        = string
}

variable "monitoring_identity_client_id" {
  description = "Client ID der Monitoring Workload Identity"
  type        = string
}

variable "key_vault_name" {
  description = "Name des Key Vaults"
  type        = string
}

variable "key_vault_id" {
  description = "ID des Key Vaults"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
