resource "random_password" "sql" {
  length  = 16
  special = true
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = random_password.sql.result
  tags                         = var.tags
}

resource "azurerm_mssql_database" "sqldb" {
  name                = var.sql_database_name
  
  
  server_id = azurerm_mssql_server.sql.id
  sku_name            = var.sku_name
  tags                = var.tags
}
