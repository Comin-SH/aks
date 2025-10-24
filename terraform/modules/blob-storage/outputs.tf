output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.loki.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.loki.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.loki.primary_blob_endpoint
}

output "chunks_container_name" {
  description = "Name of the chunks container"
  value       = azurerm_storage_container.chunks.name
}

output "ruler_container_name" {
  description = "Name of the ruler container"
  value       = azurerm_storage_container.ruler.name
}
