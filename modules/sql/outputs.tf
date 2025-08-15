output "sql_server_name" {
  value = azurerm_mssql_server.sql.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sqldb.name
}

output "sql_server_admin_password" {
  value     = random_password.sql.result
  sensitive = true
}
