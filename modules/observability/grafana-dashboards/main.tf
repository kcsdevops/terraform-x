# Grafana Dashboards Module
# Criação de dashboards personalizados para monitoração

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

# Variables
variable "grafana_url" {
  description = "URL do Grafana"
  type        = string
}

variable "grafana_auth" {
  description = "Token de autenticação do Grafana"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

# Dashboard de Infraestrutura Azure
resource "grafana_dashboard" "azure_infrastructure" {
  config_json = jsonencode({
    dashboard = {
      id       = null
      title    = "Azure Infrastructure Monitoring"
      tags     = ["azure", "infrastructure"]
      timezone = "browser"
      panels = [
        {
          id    = 1
          title = "CPU Usage"
          type  = "stat"
          targets = [
            {
              expr         = "avg(cpu_usage_percent)"
              legendFormat = "CPU Usage %"
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
                  { color = "yellow", value = 70 },
                  { color = "red", value = 90 }
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
        }
      ]
      time = {
        from = "now-1h"
        to   = "now"
      }
      refresh = "30s"
    }
  })
}

# Outputs
output "dashboard_urls" {
  description = "URLs dos dashboards criados"
  value = {
    azure_infrastructure = "grafana_url/d/azure-infra"
  }
}
