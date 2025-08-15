# Outputs for Prometheus Monitoring Module

# Resource Group Information
output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = local.resource_group.id
}

output "location" {
  description = "Azure region of the resources"
  value       = local.resource_group.location
}

# Container App Environment
output "container_app_environment_id" {
  description = "ID of the Container App Environment"
  value       = azurerm_container_app_environment.monitoring.id
}

output "container_app_environment_name" {
  description = "Name of the Container App Environment"
  value       = azurerm_container_app_environment.monitoring.name
}

# Prometheus
output "prometheus_fqdn" {
  description = "FQDN of the Prometheus Container App"
  value       = azurerm_container_app.prometheus.latest_revision_fqdn
}

output "prometheus_url" {
  description = "URL of the Prometheus web interface"
  value       = var.prometheus_external_access ? "https://UTF8{azurerm_container_app.prometheus.latest_revision_fqdn}" : null
}

output "prometheus_container_app_id" {
  description = "ID of the Prometheus Container App"
  value       = azurerm_container_app.prometheus.id
}

# Grafana
output "grafana_fqdn" {
  description = "FQDN of the Grafana Container App (if separate)"
  value       = var.create_separate_grafana ? azurerm_container_app.grafana[0].latest_revision_fqdn : null
}

output "grafana_url" {
  description = "URL of the Grafana web interface"
  value       = var.create_separate_grafana && var.grafana_external_access ? "https://UTF8{azurerm_container_app.grafana[0].latest_revision_fqdn}" : null
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = "admin"
}

output "grafana_admin_password_secret_name" {
  description = "Name of the Key Vault secret containing Grafana admin password"
  value       = azurerm_key_vault_secret.grafana_admin_password.name
}

# AlertManager
output "alertmanager_fqdn" {
  description = "FQDN of the AlertManager Container App"
  value       = var.enable_alertmanager ? azurerm_container_app.alertmanager[0].latest_revision_fqdn : null
}

output "alertmanager_url" {
  description = "URL of the AlertManager web interface"
  value       = var.enable_alertmanager && var.alertmanager_external_access ? "https://UTF8{azurerm_container_app.alertmanager[0].latest_revision_fqdn}" : null
}

# Log Analytics Workspace
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.monitoring.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.monitoring.name
}

output "log_analytics_workspace_key" {
  description = "Primary shared key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.monitoring.primary_shared_key
  sensitive   = true
}

# Application Insights
output "application_insights_id" {
  description = "ID of the Application Insights component"
  value       = azurerm_application_insights.monitoring.id
}

output "application_insights_name" {
  description = "Name of the Application Insights component"
  value       = azurerm_application_insights.monitoring.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key of the Application Insights component"
  value       = azurerm_application_insights.monitoring.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string of the Application Insights component"
  value       = azurerm_application_insights.monitoring.connection_string
  sensitive   = true
}

# Key Vault
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.monitoring.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.monitoring.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.monitoring.vault_uri
}

# Managed Identity
output "managed_identity_id" {
  description = "ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.monitoring.id
}

output "managed_identity_client_id" {
  description = "Client ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.monitoring.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the User Assigned Managed Identity"
  value       = azurerm_user_assigned_identity.monitoring.principal_id
}

# Storage Account
output "storage_account_id" {
  description = "ID of the Storage Account"
  value       = azurerm_storage_account.prometheus.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.prometheus.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key of the Storage Account"
  value       = azurerm_storage_account.prometheus.primary_access_key
  sensitive   = true
}

# Network Information
output "virtual_network_id" {
  description = "ID of the Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.monitoring[0].id : null
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.monitoring[0].name : null
}

output "subnet_id" {
  description = "ID of the monitoring subnet"
  value       = var.create_vnet ? azurerm_subnet.monitoring[0].id : var.existing_subnet_id
}

# Private Link Information
output "private_link_scope_id" {
  description = "ID of the Azure Monitor Private Link Scope"
  value       = var.enable_private_link ? azurerm_monitor_private_link_scope.monitoring[0].id : null
}

# Monitoring Endpoints
output "monitoring_endpoints" {
  description = "Map of monitoring service endpoints"
  value = {
    prometheus_metrics    = var.prometheus_external_access ? "https://UTF8{azurerm_container_app.prometheus.latest_revision_fqdn}/metrics" : null
    prometheus_targets    = var.prometheus_external_access ? "https://UTF8{azurerm_container_app.prometheus.latest_revision_fqdn}/targets" : null
    prometheus_config     = var.prometheus_external_access ? "https://UTF8{azurerm_container_app.prometheus.latest_revision_fqdn}/config" : null
    grafana_dashboard     = var.create_separate_grafana && var.grafana_external_access ? "https://UTF8{azurerm_container_app.grafana[0].latest_revision_fqdn}" : null
    alertmanager_alerts   = var.enable_alertmanager && var.alertmanager_external_access ? "https://UTF8{azurerm_container_app.alertmanager[0].latest_revision_fqdn}/#/alerts" : null
    node_exporter_metrics = "http://localhost:9100/metrics"
    otel_collector_health = "http://localhost:13133/"
  }
}

# Configuration Information
output "configuration_info" {
  description = "Important configuration information"
  value = {
    prometheus_config_secret = azurerm_key_vault_secret.prometheus_config.name
    grafana_admin_secret     = azurerm_key_vault_secret.grafana_admin_password.name
    storage_shares = {
      config = azurerm_storage_share.prometheus_config.name
      data   = azurerm_storage_share.prometheus_data.name
    }
    sidecar_containers = {
      grafana        = "http://localhost:3000"
      node_exporter  = "http://localhost:9100"
      otel_collector = "http://localhost:4317"
    }
  }
}
