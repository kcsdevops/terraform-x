# Prometheus Monitoring - Homologation Environment
# Production-like monitoring setup with enhanced features

# Homologation Prometheus Monitoring
module "prometheus_monitoring_homolog" {
  source = "../modules/prometheus-monitoring"

  # Resource Group Configuration
  create_resource_group = true
  resource_group_name  = "rg-monitoring-homolog-network.tf{random_string.env_suffix.result}"
  location            = "East US"
  name_prefix         = "hmg-prom"

  # Network Configuration
  create_vnet           = true
  vnet_address_space    = "10.2.0.0/16"
  subnet_address_prefix = "10.2.1.0/24"
  zone_redundancy_enabled = true  # Enable for production-like environment

  # Prometheus Configuration - Enhanced for homolog
  prometheus_cpu         = "1.5"
  prometheus_memory      = "3Gi"
  prometheus_min_replicas = 2
  prometheus_max_replicas = 4
  prometheus_external_access = true
  prometheus_storage_size_gb = 100

  # Grafana Configuration - Separate instance for better performance
  create_separate_grafana = true
  grafana_cpu_dedicated  = "1.0"
  grafana_memory_dedicated = "2Gi"
  grafana_min_replicas   = 1
  grafana_max_replicas   = 3
  grafana_external_access = true
  grafana_plugins = "grafana-azure-monitor-datasource,grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel"

  # APM Configuration - Enhanced
  apm_cpu    = "0.5"
  apm_memory = "1Gi"

  # Storage Configuration - Better replication for homolog
  storage_replication_type = "ZRS"

  # Log Analytics - Enhanced retention
  log_analytics_sku    = "PerGB2018"
  log_retention_days   = 90

  # Optional Features - Enabled for homolog
  enable_alertmanager = true
  alertmanager_external_access = false  # Internal only for security
  enable_private_link = true

  tags = {
    Environment = "Homologation"
    Project     = "Monitoring"
    Purpose     = "QA-Testing"
    CostCenter  = "IT-QA"
    Owner       = "QA Team"
    ManagedBy   = "Terraform"
    Criticality = "High"
  }
}

# Random suffix for unique resource names
resource "random_string" "env_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Outputs for homolog environment
output "homolog_prometheus_url" {
  description = "Prometheus URL for homologation environment"
  value       = module.prometheus_monitoring_homolog.prometheus_url
}

output "homolog_grafana_url" {
  description = "Grafana URL for homologation environment"
  value       = module.prometheus_monitoring_homolog.grafana_url
}

output "homolog_alertmanager_url" {
  description = "AlertManager URL for homologation environment"
  value       = module.prometheus_monitoring_homolog.alertmanager_url
}

output "homolog_application_insights_connection" {
  description = "Application Insights connection string for homolog apps"
  value       = module.prometheus_monitoring_homolog.application_insights_connection_string
  sensitive   = true
}

output "homolog_log_analytics_workspace" {
  description = "Log Analytics workspace for homolog environment"
  value       = module.prometheus_monitoring_homolog.log_analytics_workspace_name
}

output "homolog_monitoring_endpoints" {
  description = "All monitoring endpoints for homologation"
  value       = module.prometheus_monitoring_homolog.monitoring_endpoints
}

output "homolog_key_vault_name" {
  description = "Key Vault name for secrets"
  value       = module.prometheus_monitoring_homolog.key_vault_name
}
