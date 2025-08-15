// App Service Plan
resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
  tags = var.tags
}

// App Services
resource "azurerm_app_service" "core" {
  name                = var.core_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags
  site_config {
    linux_fx_version = var.container_image != "" ? "DOCKER|${var.container_image}" : null
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "core" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_app_service.core.id
  subnet_id      = var.subnet_id
}
resource "azurerm_app_service" "history" {
  name                = var.history_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags
  site_config {
    linux_fx_version = var.container_image != "" ? "DOCKER|${var.container_image}" : null
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "history" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_app_service.history.id
  subnet_id      = var.subnet_id
}
resource "azurerm_app_service" "master" {
  name                = var.master_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  tags                = var.tags
  site_config {
    linux_fx_version = var.container_image != "" ? "DOCKER|${var.container_image}" : null
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "master" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_app_service.master.id
  subnet_id      = var.subnet_id
}
