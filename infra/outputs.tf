// outputs.tf - Outputs úteis

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_location" {
  value = azurerm_resource_group.main.location
}

// Adicione outros outputs conforme necessário (endpoints, connection strings, etc)
