# Prometheus Monitoring - Development Environment
# Basic monitoring setup for development with minimal resources

# Development Prometheus Monitoring
module "prometheus_monitoring_dev" {
  source = "../modules/prometheus-monitoring"

  # Resource Group Configuration
  create_resource_group = true
  resource_group_name  = "rg-monitoring-dev-validate{random_string.env_suffix.result}"
  location            = "East US"
  name_prefix         = "dev-prom"

  # Network Configuration
  create_vnet           = true
  vnet_address_space    = "10.1.0.0/16"
  subnet_address_prefix = "10.1.1.0/24"
  zone_redundancy_enabled = false  # Disabled for dev to reduce costs

  # Prometheus Configuration - Minimal for dev
  prometheus_cpu         = "0.5"
  prometheus_memory      = "1Gi"
  prometheus_min_replicas = 1
  prometheus_max_replicas = 2
  prometheus_external_access = true
  prometheus_storage_size_gb = 20

  # Grafana Configuration
  create_separate_grafana = false  # Use sidecar for simplicity
  grafana_cpu            = "0.25"
  grafana_memory         = "0.5Gi"
  grafana_external_access = true

  # APM Configuration
  apm_cpu    = "0.1"
  apm_memory = "0.25Gi"

  # Node Exporter (built-in sidecar)
  node_exporter_image = "prom/node-exporter:latest"

  # Storage Configuration
  storage_replication_type = "LRS"  # Cheaper option for dev

  # Log Analytics
  log_analytics_sku    = "PerGB2018"
  log_retention_days   = 30

  # Optional Features - Disabled for dev
  enable_alertmanager = false
  enable_private_link = false

  # Custom Prometheus Configuration for Development
  prometheus_config = <<-EOT
global:
  scrape_interval: 30s
  evaluation_interval: 30s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'otel-collector'
    static_configs:
      - targets: ['localhost:8888']

  # Example: Monitor development applications
  - job_name: 'dev-apps'
    static_configs:
      - targets: []  # Add your dev app endpoints here
    scrape_interval: 60s

  # Azure Container Apps monitoring
  - job_name: 'azure-container-apps-dev'
    azure_sd_configs:
      - subscription_id: ''  # Will be populated automatically
        resource_group: 'rg-apps-dev'
        port: 80
    relabel_configs:
      - source_labels: [__meta_azure_machine_tag_environment]
        target_label: environment
      - source_labels: [__meta_azure_machine_name]
        target_label: instance
EOT

  tags = {
    Environment = "Development"
    Project     = "Monitoring"
    Purpose     = "DevOps"
    CostCenter  = "IT-Dev"
    Owner       = "DevOps Team"
    ManagedBy   = "Terraform"
  }
}

# Random suffix for unique resource names
resource "random_string" "env_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Output development information
output "dev_prometheus_url" {
  description = "Prometheus URL for development environment"
  value       = module.prometheus_monitoring_dev.prometheus_url
}

output "dev_grafana_url" {
  description = "Grafana URL for development environment (sidecar)"
  value       = "Port forward to access Grafana: az containerapp exec --name validate{split("/", module.prometheus_monitoring_dev.prometheus_container_app_id)[8]} --container grafana --command '/bin/bash'"
}

output "dev_application_insights_connection" {
  description = "Application Insights connection string for dev apps"
  value       = module.prometheus_monitoring_dev.application_insights_connection_string
  sensitive   = true
}

output "dev_log_analytics_workspace" {
  description = "Log Analytics workspace for dev environment"
  value       = module.prometheus_monitoring_dev.log_analytics_workspace_name
}

output "dev_monitoring_endpoints" {
  description = "All monitoring endpoints for development"
  value       = module.prometheus_monitoring_dev.monitoring_endpoints
}

output "dev_key_vault_name" {
  description = "Key Vault name for secrets (contains Grafana password)"
  value       = module.prometheus_monitoring_dev.key_vault_name
}

# Quick access commands
output "dev_access_commands" {
  description = "Commands to access monitoring services"
  value = {
    prometheus_targets = "curl validate{module.prometheus_monitoring_dev.prometheus_url}/targets"
    prometheus_metrics = "curl validate{module.prometheus_monitoring_dev.prometheus_url}/metrics"
    grafana_password   = "az keyvault secret show --vault-name validate{module.prometheus_monitoring_dev.key_vault_name} --name grafana-admin-password --query value -o tsv"
    container_logs     = "az containerapp logs show --name validate{split("/", module.prometheus_monitoring_dev.prometheus_container_app_id)[8]} --resource-group validate{module.prometheus_monitoring_dev.resource_group_name}"
  }
}
