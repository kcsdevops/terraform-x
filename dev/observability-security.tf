# Observability & Security Configuration
# Configuração básica de monitoramento e segurança

# Data source para subscription atual
data "azurerm_client_config" "current" {}

# Application Insights para monitoramento básico
resource "azurerm_application_insights" "main" {
  name                 = "dev-appinsights-obs"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  application_type     = "web"
  retention_in_days    = 30

  tags = merge(module.tags_sql.tags_with_additional, {
    Component = "Observability"
    Service   = "ApplicationInsights"
  })
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "dev-law-obs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(module.tags_sql.tags_with_additional, {
    Component = "Observability"
    Service   = "LogAnalytics"
  })
}

# Security Center (Microsoft Defender for Cloud)
resource "azurerm_security_center_subscription_pricing" "main" {
  tier          = "Free"  # Free tier para dev
  resource_type = "VirtualMachines"
}

# Outputs de Observabilidade
output "observability_info" {
  description = "Informações de observabilidade"
  value = {
    application_insights_key = azurerm_application_insights.main.instrumentation_key
    application_insights_id  = azurerm_application_insights.main.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    log_analytics_workspace_key = azurerm_log_analytics_workspace.main.primary_shared_key
    resource_group = azurerm_resource_group.main.name
  }
  sensitive = true
}

# Outputs de Segurança
output "security_info" {
  description = "Informações de segurança"
  value = {
    subscription_id = data.azurerm_client_config.current.subscription_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
    security_center_enabled = "Free Tier"
  }
}
