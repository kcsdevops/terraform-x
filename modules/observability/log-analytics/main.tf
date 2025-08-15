# Log Analytics Module
# Centralização de logs e análise

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização dos recursos"
  type        = string
}

variable "name_prefix" {
  description = "Prefixo para nomes dos recursos"
  type        = string
}

variable "retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "\-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "\-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = var.tags
}

# Saved Searches para queries comuns
resource "azurerm_log_analytics_saved_search" "error_logs" {
  name                       = "ErrorLogs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  category                   = "Application"
  display_name              = "Application Errors"
  query                     = <<-EOQ
AppTraces
| where SeverityLevel >= 3
| summarize Count = count() by bin(TimeGenerated, 5m), SeverityLevel
| order by TimeGenerated desc
EOQ
}

resource "azurerm_log_analytics_saved_search" "performance_logs" {
  name                       = "PerformanceLogs"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  category                   = "Performance"
  display_name              = "Performance Metrics"
  query                     = <<-EOQ
AppMetrics
| where Name in ("requests/count", "requests/duration")
| summarize Avg = avg(Value), Max = max(Value) by bin(TimeGenerated, 5m), Name
| order by TimeGenerated desc
EOQ
}

# Outputs
output "workspace_id" {
  description = "ID do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_key" {
  description = "Chave do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "application_insights_key" {
  description = "Chave do Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection String do Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
