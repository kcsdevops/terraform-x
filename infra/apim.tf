// API Management
resource "azurerm_api_management" "apim" {
  name                = "${var.resource_group_name}-apim"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Financeiro"
  publisher_email     = "admin@financeiro.com"
  sku_name            = "Developer_1"
}
