# Security Alerts Module
# Alertas de segurança e monitoramento

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

variable "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  type        = string
}

variable "action_group_name" {
  description = "Nome do Action Group para notificações"
  type        = string
  default     = "security-alerts"
}

variable "email_notifications" {
  description = "Lista de emails para notificações"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

# Action Group para notificações
resource "azurerm_monitor_action_group" "security" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = "secsoc"

  dynamic "email_receiver" {
    for_each = var.email_notifications
    content {
      name          = "email-\"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Alert para tentativas de login falhadas
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_logins" {
  name                = "high-failed-logins"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration     = "PT15M"
  scopes              = [var.log_analytics_workspace_id]
  severity            = 2

  criteria {
    query                   = <<-QUERY
SigninLogs
| where ResultType != 0
| summarize FailedAttempts = count() by UserPrincipalName, bin(TimeGenerated, 5m)
| where FailedAttempts > 5
QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.security.id]
  }

  description = "Alert when user has more than 5 failed login attempts in 5 minutes"
  tags        = var.tags
}

# Alert para mudanças de recursos críticos
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "critical_resource_changes" {
  name                = "critical-resource-changes"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration     = "PT5M"
  scopes              = [var.log_analytics_workspace_id]
  severity            = 1

  criteria {
    query                   = <<-QUERY
AzureActivity
| where OperationNameValue in ("Microsoft.KeyVault/vaults/write", "Microsoft.KeyVault/vaults/delete",
                               "Microsoft.Network/networkSecurityGroups/write", "Microsoft.Network/networkSecurityGroups/delete",
                               "Microsoft.Authorization/roleAssignments/write", "Microsoft.Authorization/roleAssignments/delete")
| where ActivityStatusValue == "Success"
QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.security.id]
  }

  description = "Alert when critical Azure resources are modified"
  tags        = var.tags
}

# Alert para acessos suspeitos
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "suspicious_access" {
  name                = "suspicious-access-patterns"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT15M"
  window_duration     = "PT1H"
  scopes              = [var.log_analytics_workspace_id]
  severity            = 2

  criteria {
    query                   = <<-QUERY
SigninLogs
| where ResultType == 0
| extend Country = tostring(LocationDetails.countryOrRegion)
| summarize Countries = dcount(Country) by UserPrincipalName, bin(TimeGenerated, 1h)
| where Countries > 2
QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.security.id]
  }

  description = "Alert when user accesses from multiple countries in 1 hour"
  tags        = var.tags
}

# Alert para violações de NSG
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "nsg_violations" {
  name                = "network-security-violations"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration     = "PT15M"
  scopes              = [var.log_analytics_workspace_id]
  severity            = 2

  criteria {
    query                   = <<-QUERY
AzureNetworkAnalytics_CL
| where FlowStatus_s == "D"
| summarize DeniedCount = count() by SourceIP = SrcIP_s, bin(TimeGenerated, 5m)
| where DeniedCount > 100
QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.security.id]
  }

  description = "Alert when IP has more than 100 denied connections in 5 minutes"
  tags        = var.tags
}

# Outputs
output "action_group_id" {
  description = "ID do Action Group"
  value       = azurerm_monitor_action_group.security.id
}

output "alert_rules" {
  description = "IDs das regras de alerta criadas"
  value = {
    failed_logins          = azurerm_monitor_scheduled_query_rules_alert_v2.failed_logins.id
    critical_changes       = azurerm_monitor_scheduled_query_rules_alert_v2.critical_resource_changes.id
    suspicious_access      = azurerm_monitor_scheduled_query_rules_alert_v2.suspicious_access.id
    nsg_violations        = azurerm_monitor_scheduled_query_rules_alert_v2.nsg_violations.id
  }
}
