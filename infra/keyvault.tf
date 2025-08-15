// Key Vault para segredos
resource "azurerm_key_vault" "main" {
  name                     = "${var.resource_group_name}kv"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
}

data "azurerm_client_config" "current" {}
