variable "resource_group_location" {
  type        = string
  default     = "germanywestcentral"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "k8s-rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "agent_pool_node_count" {
  type        = number
  description = "The initial quantity of nodes for the agent node pool."
  default     = 1
}

variable "agent_pool_vm_size" {
  type        = string
  description = "The vm size of the agentpool nodes."
  default     = "Standard_D2as_v5"
}

variable "user_pool_node_count" {
  type        = number
  description = "The initial quantity of nodes for the user node pool."
  default     = 1
}

variable "user_pool_vm_size" {
  type        = string
  description = "The vm size of the agentpool nodes."
  default     = "Standard_D2as_v5"
}

variable "cluster_name" {
  type        = string
  description = "The name of the k8s cluster"
  default     = "k8s"
}

variable "dns_prefix" {
  type        = string
  description = "The dns prefix of the k8s cluster"
  default     = "k8s"
}

variable "admin_group_object_ids" {
  description = "aks admin group ids"
  type        = list(string)
  default     = []
}

variable "rbac_reader_group_object_ids" {
  description = "Object IDs of groups that should get the 'Kubernetes Service RBAC Reader' role"
  type        = list(string)
  default     = []
}

variable "rbac_admin_group_object_ids" {
  description = "Object IDs of groups that should get the 'Kubernetes Service RBAC Cluster Admin' role"
  type        = list(string)
  default     = []
}

variable "subscription_id" {
  type        = string
  description = "The subscription id to deploy the resources to."
}

variable "STORAGE_ACCOUNT_NAME" {
  type        = string
  description = "Name des Storage Accounts für Loki"
}

variable "STORAGE_ACCOUNT_LOCATION" {
  type        = string
  description = "Standort des Storage Accounts für Loki"
  default     = "germanywestcentral"
}

variable "workload_identity_name" {
  type        = string
  description = "Name der Workload Identity (User Assigned Managed Identity) für den Zugriff auf den Blob Storage"
}

variable "keyvault_name" {
  type        = string
  description = "Name des Azure Key Vaults"
}


variable "SECRET_GRAFANA_ADMIN_PASSWORD" {
  type        = string
  description = "Wert des Secrets im Key Vault für Grafana Admin"
}

locals {
  all_aks_users = setunion(var.rbac_reader_group_object_ids, var.rbac_admin_group_object_ids)
}
