// Static Web App
resource "azurerm_static_site" "web" {
  name                = "${var.resource_group_name}-staticweb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = "Standard"
}
