output "storage_account_name" { value = azurerm_storage_account.storage.name }
output "blob_container_name" { value = azurerm_storage_container.blob.name }
output "queue_name" { value = azurerm_storage_queue.queue.name }
