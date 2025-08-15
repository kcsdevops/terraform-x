// Módulo Private Endpoint para ACR
resource "azurerm_private_endpoint" "acr" {
  name                = var.pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "acr-priv-conn"
    private_connection_resource_id = var.acr_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  tags = var.tags
}
