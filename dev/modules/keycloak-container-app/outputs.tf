# Keycloak Container App Module Outputs

output "keycloak_url" {
  description = "URL to access Keycloak"
  value       = "https://${azurerm_container_app.keycloak.latest_revision_fqdn}"
}

output "keycloak_admin_url" {
  description = "URL to access Keycloak admin console"
  value       = "https://${azurerm_container_app.keycloak.latest_revision_fqdn}/admin"
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.keycloak.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.keycloak.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.keycloak.vault_uri
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = azurerm_user_assigned_identity.keycloak.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.keycloak.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.keycloak.client_id
}

output "postgres_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.keycloak.fqdn
}

output "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.keycloak.name
}

output "postgres_database_name" {
  description = "Name of the Keycloak database"
  value       = azurerm_postgresql_flexible_server_database.keycloak.name
}

output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.keycloak.name
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.keycloak.latest_revision_fqdn
}

output "container_app_environment_id" {
  description = "ID of the Container Apps Environment"
  value       = azurerm_container_app_environment.keycloak.id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.keycloak.id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.keycloak.name
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet"
  value       = azurerm_subnet.container_apps.id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.database.id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.keycloak.id
}

output "admin_credentials" {
  description = "Admin credentials information"
  value = {
    username                  = var.keycloak_admin_username
    password_key_vault_secret = "keycloak-admin-password"
  }
  sensitive = true
}

output "database_credentials" {
  description = "Database credentials information"
  value = {
    username                  = var.postgres_admin_username
    password_key_vault_secret = "keycloak-db-password"
    server_fqdn               = azurerm_postgresql_flexible_server.keycloak.fqdn
    database_name             = azurerm_postgresql_flexible_server_database.keycloak.name
  }
  sensitive = true
}
