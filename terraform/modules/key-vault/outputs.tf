output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "monitoring_identity_id" {
  description = "The ID of the monitoring user assigned identity"
  value       = azurerm_user_assigned_identity.monitoring.id
}

output "monitoring_identity_client_id" {
  description = "The client ID of the monitoring user assigned identity"
  value       = azurerm_user_assigned_identity.monitoring.client_id
}

output "monitoring_identity_principal_id" {
  description = "The principal ID of the monitoring user assigned identity"
  value       = azurerm_user_assigned_identity.monitoring.principal_id
}
