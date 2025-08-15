// Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "${replace(var.resource_group_name, "-", "")}stg"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Blob Container
resource "azurerm_storage_container" "blob" {
  name                  = "staticfiles"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

// Queue
resource "azurerm_storage_queue" "queue" {
  name                 = "mainqueue"
  storage_account_name = azurerm_storage_account.storage.name
}
