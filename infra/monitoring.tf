// Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.resource_group_name}-appi"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}
// New Relic pode ser integrado via extensão ou agente na aplicação (não provisionado diretamente via Azure)
