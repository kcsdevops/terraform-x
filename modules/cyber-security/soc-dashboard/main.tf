# SOC Dashboard Module
# Dashboard de Segurança e Centro de Operações

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~>2.0"
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

variable "grafana_url" {
  description = "URL do Grafana"
  type        = string
}

variable "grafana_auth" {
  description = "Token de autenticação do Grafana"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

# Provider Grafana
provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_auth
}

# Dashboard SOC Principal
resource "grafana_dashboard" "soc_main" {
  config_json = jsonencode({
    dashboard = {
      id       = null
      title    = "SOC - Security Operations Center"
      tags     = ["security", "soc", "azure"]
      timezone = "browser"
      panels = [
        {
          id    = 1
          title = "Security Alerts - Last 24h"
          type  = "stat"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
SecurityAlert
| where TimeGenerated > ago(24h)
| summarize Count = count() by AlertSeverity
| project AlertSeverity, Count
EOQ
              }
            }
          ]
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds"
              }
              thresholds = {
                steps = [
                  { color = "green", value = null },
                  { color = "yellow", value = 10 },
                  { color = "red", value = 50 }
                ]
              }
            }
          }
          gridPos = {
            h = 8
            w = 6
            x = 0
            y = 0
          }
        },
        {
          id    = 2
          title = "Failed Login Attempts"
          type  = "timeseries"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
SigninLogs
| where ResultType != 0
| summarize FailedLogins = count() by bin(TimeGenerated, 1h)
| order by TimeGenerated desc
EOQ
              }
            }
          ]
          gridPos = {
            h = 8
            w = 9
            x = 6
            y = 0
          }
        },
        {
          id    = 3
          title = "Top Attack Sources"
          type  = "table"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
SecurityEvent
| where EventID in (4625, 4771)
| extend SourceIP = case(
    EventID == 4625, tostring(parse_json(EventData).IpAddress),
    EventID == 4771, tostring(parse_json(EventData).IpAddress),
    ""
)
| where isnotempty(SourceIP)
| summarize Attempts = count() by SourceIP
| top 10 by Attempts desc
EOQ
              }
            }
          ]
          gridPos = {
            h = 8
            w = 9
            x = 15
            y = 0
          }
        },
        {
          id    = 4
          title = "Azure Resource Changes"
          type  = "timeseries"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
AzureActivity
| where OperationNameValue contains "write" or OperationNameValue contains "delete"
| summarize Changes = count() by bin(TimeGenerated, 1h), OperationNameValue
| order by TimeGenerated desc
EOQ
              }
            }
          ]
          gridPos = {
            h = 8
            w = 12
            x = 0
            y = 8
          }
        },
        {
          id    = 5
          title = "Network Security Group Events"
          type  = "stat"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
AzureNetworkAnalytics_CL
| where FlowStatus_s == "D" // Denied flows
| summarize DeniedConnections = count() by bin(TimeGenerated, 1h)
| summarize Total = sum(DeniedConnections)
EOQ
              }
            }
          ]
          gridPos = {
            h = 8
            w = 12
            x = 12
            y = 8
          }
        }
      ]
      time = {
        from = "now-24h"
        to   = "now"
      }
      refresh = "5m"
    }
  })
}

# Dashboard de Compliance
resource "grafana_dashboard" "compliance" {
  config_json = jsonencode({
    dashboard = {
      id       = null
      title    = "Compliance & Governance Dashboard"
      tags     = ["compliance", "governance", "lgpd"]
      timezone = "browser"
      panels = [
        {
          id    = 1
          title = "LGPD Compliance Score"
          type  = "gauge"
          targets = [
            {
              expr = "100 - (failed_compliance_checks / total_compliance_checks * 100)"
            }
          ]
          fieldConfig = {
            defaults = {
              min = 0
              max = 100
              thresholds = {
                steps = [
                  { color = "red", value = 0 },
                  { color = "yellow", value = 70 },
                  { color = "green", value = 90 }
                ]
              }
            }
          }
          gridPos = {
            h = 8
            w = 12
            x = 0
            y = 0
          }
        },
        {
          id    = 2
          title = "Data Access Logs"
          type  = "table"
          datasource = {
            type = "azuremonitor"
          }
          targets = [
            {
              azureLogAnalytics = {
                query = <<-EOQ
AuditLogs
| where Category == "DataAccess"
| project TimeGenerated, UserPrincipalName, OperationName, Result
| order by TimeGenerated desc
| limit 100
EOQ
              }
            }
          ]
          gridPos = {
            h = 8
            w = 12
            x = 12
            y = 0
          }
        }
      ]
      time = {
        from = "now-7d"
        to   = "now"
      }
      refresh = "1h"
    }
  })
}

# Outputs
output "soc_dashboard_url" {
  description = "URL do dashboard SOC"
  value       = "\/d/\"
}

output "compliance_dashboard_url" {
  description = "URL do dashboard de compliance"
  value       = "\/d/\"
}

output "dashboard_ids" {
  description = "IDs dos dashboards"
  value = {
    soc_main    = grafana_dashboard.soc_main.id
    compliance = grafana_dashboard.compliance.id
  }
}
