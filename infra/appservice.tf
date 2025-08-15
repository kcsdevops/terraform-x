// App Service Plan
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.resource_group_name}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

// App Services (Core, History, Master)
resource "azurerm_app_service" "core" {
  name                = "${var.resource_group_name}-core"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
}

resource "azurerm_app_service" "history" {
  name                = "${var.resource_group_name}-history"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
}

resource "azurerm_app_service" "master" {
  name                = "${var.resource_group_name}-master"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
}
