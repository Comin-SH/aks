variable "location" {
  type        = string
  description = "Azure region where the AKS cluster will be deployed"
}

variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the AKS cluster"
}

variable "local_account_disabled" {
  type        = bool
  description = "Whether to disable local accounts"
  default     = false
}

variable "agent_pool_vm_size" {
  type        = string
  description = "VM size for the default agent pool"
  default     = "Standard_D2as_v5"
}

variable "agent_pool_node_count" {
  type        = number
  description = "Number of nodes in the default agent pool"
  default     = 1
}

variable "user_pool_vm_size" {
  type        = string
  description = "VM size for the user node pool"
  default     = "Standard_D2as_v5"
}

variable "user_pool_node_count" {
  type        = number
  description = "Number of nodes in the user node pool"
  default     = 1
}

variable "admin_group_object_ids" {
  type        = list(string)
  description = "Object IDs of Azure AD groups that should have admin access"
  default     = []
}

variable "rbac_reader_group_object_ids" {
  type        = list(string)
  description = "Object IDs of groups that should get the 'Kubernetes Service RBAC Reader' role"
  default     = []
}

variable "rbac_admin_group_object_ids" {
  type        = list(string)
  description = "Object IDs of groups that should get the 'Kubernetes Service RBAC Cluster Admin' role"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
