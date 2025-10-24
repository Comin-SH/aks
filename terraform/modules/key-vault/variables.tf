variable "keyvault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD Tenant ID"
}

variable "admin_principal_id" {
  type        = string
  description = "Principal ID (Object ID) of the admin user/service principal"
}

variable "grafana_admin_password" {
  type        = string
  description = "Admin password for Grafana"
  sensitive   = true
}

variable "workload_identity_name" {
  type        = string
  description = "Name of the workload identity for monitoring"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL from the AKS cluster"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection for the Key Vault"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
