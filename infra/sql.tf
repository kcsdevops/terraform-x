// Azure SQL Server
resource "random_password" "sql" {
  length  = 16
  special = true
}

resource "azurerm_sql_server" "sql" {
  name                         = "${var.resource_group_name}-sqlsrv"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = random_password.sql.result
}

resource "azurerm_sql_database" "sqldb" {
  name                = "${var.resource_group_name}-sqldb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  server_name         = azurerm_sql_server.sql.name
  sku_name            = "S0"
}
