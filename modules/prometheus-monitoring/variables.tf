# Variables for Prometheus Monitoring Module

# Resource Group Configuration
variable "create_resource_group" {
  description = "Whether to create a new resource group"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "prom"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Monitoring"
    ManagedBy   = "Terraform"
  }
}

# Network Configuration
variable "create_vnet" {
  description = "Whether to create a new virtual network"
  type        = bool
  default     = true
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the monitoring subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "existing_subnet_id" {
  description = "ID of existing subnet (used when create_vnet is false)"
  type        = string
  default     = null
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for container app environment"
  type        = bool
  default     = false
}

# Log Analytics Configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, Standalone, PerNode, PerGB2018."
  }
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

# Storage Configuration
variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "prometheus_storage_size_gb" {
  description = "Storage size for Prometheus data in GB"
  type        = number
  default     = 100
}

# Prometheus Configuration
variable "prometheus_image" {
  description = "Prometheus container image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "prometheus_cpu" {
  description = "CPU allocation for Prometheus container"
  type        = string
  default     = "1.0"
}

variable "prometheus_memory" {
  description = "Memory allocation for Prometheus container"
  type        = string
  default     = "2Gi"
}

variable "prometheus_min_replicas" {
  description = "Minimum number of Prometheus replicas"
  type        = number
  default     = 1
}

variable "prometheus_max_replicas" {
  description = "Maximum number of Prometheus replicas"
  type        = number
  default     = 3
}

variable "prometheus_external_access" {
  description = "Enable external access to Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_config" {
  description = "Prometheus configuration YAML"
  type        = string
  default     = <<-EOT
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'azure-container-apps'
    azure_sd_configs:
      - subscription_id: ''
        resource_group: ''
        port: 80

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093
EOT
}

# Grafana Configuration
variable "grafana_image" {
  description = "Grafana container image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "grafana_cpu" {
  description = "CPU allocation for Grafana sidecar container"
  type        = string
  default     = "0.5"
}

variable "grafana_memory" {
  description = "Memory allocation for Grafana sidecar container"
  type        = string
  default     = "1Gi"
}

variable "grafana_cpu_dedicated" {
  description = "CPU allocation for dedicated Grafana container"
  type        = string
  default     = "1.0"
}

variable "grafana_memory_dedicated" {
  description = "Memory allocation for dedicated Grafana container"
  type        = string
  default     = "2Gi"
}

variable "grafana_min_replicas" {
  description = "Minimum number of Grafana replicas (when separate)"
  type        = number
  default     = 1
}

variable "grafana_max_replicas" {
  description = "Maximum number of Grafana replicas (when separate)"
  type        = number
  default     = 2
}

variable "grafana_external_access" {
  description = "Enable external access to Grafana"
  type        = bool
  default     = true
}

variable "grafana_plugins" {
  description = "Grafana plugins to install"
  type        = string
  default     = "grafana-azure-monitor-datasource,grafana-clock-panel,grafana-simple-json-datasource"
}

variable "create_separate_grafana" {
  description = "Create separate Grafana container app instead of sidecar"
  type        = bool
  default     = false
}

# Node Exporter Configuration
variable "node_exporter_image" {
  description = "Node Exporter container image"
  type        = string
  default     = "prom/node-exporter:latest"
}

# APM Configuration
variable "otel_collector_image" {
  description = "OpenTelemetry Collector container image"
  type        = string
  default     = "otel/opentelemetry-collector-contrib:latest"
}

variable "apm_cpu" {
  description = "CPU allocation for APM collector container"
  type        = string
  default     = "0.25"
}

variable "apm_memory" {
  description = "Memory allocation for APM collector container"
  type        = string
  default     = "0.5Gi"
}

# AlertManager Configuration
variable "enable_alertmanager" {
  description = "Enable AlertManager deployment"
  type        = bool
  default     = false
}

variable "alertmanager_image" {
  description = "AlertManager container image"
  type        = string
  default     = "prom/alertmanager:latest"
}

variable "alertmanager_external_access" {
  description = "Enable external access to AlertManager"
  type        = bool
  default     = false
}

# Private Link Configuration
variable "enable_private_link" {
  description = "Enable Azure Monitor Private Link Scope"
  type        = bool
  default     = false
}
