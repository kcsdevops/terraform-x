# Prometheus Container App Module with Sidecar and APM
# This module creates a comprehensive monitoring solution with Prometheus, Grafana, and APM capabilities

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.117.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.7.0"
    }
  }
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "monitoring" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location

  tags = merge(var.tags, {
    Purpose = "Monitoring and Observability"
    Service = "Prometheus"
  })
}

data "azurerm_resource_group" "monitoring" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

locals {
  resource_group = var.create_resource_group ? azurerm_resource_group.monitoring[0] : data.azurerm_resource_group.monitoring[0]
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "${var.name_prefix}-law-${random_string.suffix.result}"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# Application Insights for APM
resource "azurerm_application_insights" "monitoring" {
  name                = "${var.name_prefix}-ai-${random_string.suffix.result}"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  workspace_id        = azurerm_log_analytics_workspace.monitoring.id
  application_type    = "web"

  tags = var.tags
}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "monitoring" {
  name                = "${var.name_prefix}-identity-${random_string.suffix.result}"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name

  tags = var.tags
}

# Key Vault for secrets management
resource "azurerm_key_vault" "monitoring" {
  name                = "${var.name_prefix}-kv-${random_string.suffix.result}"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.monitoring.principal_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]
  }

  tags = var.tags
}

# Current Azure client configuration
data "azurerm_client_config" "current" {}

# Virtual Network for Container App Environment
resource "azurerm_virtual_network" "monitoring" {
  count               = var.create_vnet ? 1 : 0
  name                = "${var.name_prefix}-vnet-${random_string.suffix.result}"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

# Subnet for Container App Environment
resource "azurerm_subnet" "monitoring" {
  count                = var.create_vnet ? 1 : 0
  name                 = "${var.name_prefix}-subnet-monitoring"
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.monitoring[0].name
  address_prefixes     = [var.subnet_address_prefix]

  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

# Container App Environment
resource "azurerm_container_app_environment" "monitoring" {
  name                       = "${var.name_prefix}-cae-${random_string.suffix.result}"
  location                   = local.resource_group.location
  resource_group_name        = local.resource_group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id
  infrastructure_subnet_id   = var.create_vnet ? azurerm_subnet.monitoring[0].id : var.existing_subnet_id
  zone_redundancy_enabled    = var.zone_redundancy_enabled

  tags = var.tags
}

# Storage Account for Prometheus data persistence
resource "azurerm_storage_account" "prometheus" {
  name                     = "${var.name_prefix}st${random_string.suffix.result}"
  resource_group_name      = local.resource_group.name
  location                 = local.resource_group.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# File Share for Prometheus configuration
resource "azurerm_storage_share" "prometheus_config" {
  name                 = "prometheus-config"
  storage_account_name = azurerm_storage_account.prometheus.name
  quota                = 5

  depends_on = [azurerm_storage_account.prometheus]
}

# File Share for Prometheus data
resource "azurerm_storage_share" "prometheus_data" {
  name                 = "prometheus-data"
  storage_account_name = azurerm_storage_account.prometheus.name
  quota                = var.prometheus_storage_size_gb

  depends_on = [azurerm_storage_account.prometheus]
}

# Prometheus Configuration Secret
resource "azurerm_key_vault_secret" "prometheus_config" {
  name         = "prometheus-config"
  value        = base64encode(var.prometheus_config)
  key_vault_id = azurerm_key_vault.monitoring.id

  depends_on = [azurerm_key_vault.monitoring]
}

# Grafana admin password
resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "grafana_admin_password" {
  name         = "grafana-admin-password"
  value        = random_password.grafana_admin.result
  key_vault_id = azurerm_key_vault.monitoring.id

  depends_on = [azurerm_key_vault.monitoring]
}

# Prometheus Container App
resource "azurerm_container_app" "prometheus" {
  name                         = "${var.name_prefix}-prometheus-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.monitoring.id
  resource_group_name          = local.resource_group.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.monitoring.id]
  }

  ingress {
    external_enabled = var.prometheus_external_access
    target_port      = 9090
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.prometheus_min_replicas
    max_replicas = var.prometheus_max_replicas

    container {
      name   = "prometheus"
      image  = var.prometheus_image
      cpu    = var.prometheus_cpu
      memory = var.prometheus_memory

      env {
        name  = "PROMETHEUS_STORAGE_PATH"
        value = "/prometheus/data"
      }

      env {
        name  = "PROMETHEUS_CONFIG_PATH"
        value = "/etc/prometheus/prometheus.yml"
      }

      # Volume mounts for persistent storage
      volume_mounts {
        name = "prometheus-config"
        path = "/etc/prometheus"
      }

      volume_mounts {
        name = "prometheus-data"
        path = "/prometheus/data"
      }

      # Liveness probe
      liveness_probe {
        http_get {
          path = "/-/healthy"
          port = 9090
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }

      # Readiness probe
      readiness_probe {
        http_get {
          path = "/-/ready"
          port = 9090
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }

    # Grafana sidecar container
    container {
      name   = "grafana"
      image  = var.grafana_image
      cpu    = var.grafana_cpu
      memory = var.grafana_memory

      env {
        name  = "GF_SECURITY_ADMIN_USER"
        value = "admin"
      }

      env {
        name        = "GF_SECURITY_ADMIN_PASSWORD"
        secret_name = "grafana-admin-password"
      }

      env {
        name  = "GF_DATASOURCES_DEFAULT_URL"
        value = "http://localhost:9090"
      }

      env {
        name  = "GF_DATASOURCES_DEFAULT_TYPE"
        value = "prometheus"
      }

      env {
        name  = "GF_INSTALL_PLUGINS"
        value = var.grafana_plugins
      }

      # Liveness probe for Grafana
      liveness_probe {
        http_get {
          path = "/api/health"
          port = 3000
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }

      # Readiness probe for Grafana
      readiness_probe {
        http_get {
          path = "/api/health"
          port = 3000
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }

    # Node Exporter sidecar for system metrics
    container {
      name   = "node-exporter"
      image  = var.node_exporter_image
      cpu    = "0.1"
      memory = "0.2Gi"

      env {
        name  = "NODE_EXPORTER_PORT"
        value = "9100"
      }

      # Liveness probe for Node Exporter
      liveness_probe {
        http_get {
          path = "/metrics"
          port = 9100
        }
        initial_delay_seconds = 10
        period_seconds        = 30
      }
    }

    # APM Agent sidecar (OpenTelemetry Collector)
    container {
      name   = "otel-collector"
      image  = var.otel_collector_image
      cpu    = var.apm_cpu
      memory = var.apm_memory

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.monitoring.connection_string
      }

      env {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://localhost:4317"
      }

      # Liveness probe for OTEL Collector
      liveness_probe {
        http_get {
          path = "/"
          port = 13133
        }
        initial_delay_seconds = 15
        period_seconds        = 10
      }
    }

    # Volumes for persistent storage
    volume {
      name         = "prometheus-config"
      storage_type = "AzureFile"
      storage_name = azurerm_storage_share.prometheus_config.name
    }

    volume {
      name         = "prometheus-data"
      storage_type = "AzureFile"
      storage_name = azurerm_storage_share.prometheus_data.name
    }
  }

  secret {
    name  = "grafana-admin-password"
    value = random_password.grafana_admin.result
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_secret.prometheus_config,
    azurerm_storage_share.prometheus_config,
    azurerm_storage_share.prometheus_data
  ]
}
# Grafana Container App (separate instance for better performance)
resource "azurerm_container_app" "grafana" {
  count                        = var.create_separate_grafana ? 1 : 0
  name                         = "${var.name_prefix}-grafana-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.monitoring.id
  resource_group_name          = local.resource_group.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.monitoring.id]
  }

  ingress {
    external_enabled = var.grafana_external_access
    target_port      = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.grafana_min_replicas
    max_replicas = var.grafana_max_replicas

    container {
      name   = "grafana"
      image  = var.grafana_image
      cpu    = var.grafana_cpu_dedicated
      memory = var.grafana_memory_dedicated

      env {
        name  = "GF_SECURITY_ADMIN_USER"
        value = "admin"
      }

      env {
        name        = "GF_SECURITY_ADMIN_PASSWORD"
        secret_name = "grafana-admin-password"
      }

      env {
        name  = "GF_DATASOURCES_DEFAULT_URL"
        value = "http://${azurerm_container_app.prometheus.latest_revision_fqdn}:9090"
      }

      env {
        name  = "GF_DATASOURCES_DEFAULT_TYPE"
        value = "prometheus"
      }

      env {
        name  = "GF_INSTALL_PLUGINS"
        value = var.grafana_plugins
      }

      env {
        name  = "GF_AZURE_MANAGED_IDENTITY_ENABLED"
        value = "true"
      }

      env {
        name  = "GF_AZURE_MANAGED_IDENTITY_CLIENT_ID"
        value = azurerm_user_assigned_identity.monitoring.client_id
      }

      # Liveness probe
      liveness_probe {
        http_get {
          path = "/api/health"
          port = 3000
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }

      # Readiness probe
      readiness_probe {
        http_get {
          path = "/api/health"
          port = 3000
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }
  }

  secret {
    name  = "grafana-admin-password"
    value = random_password.grafana_admin.result
  }

  tags = var.tags
}

# Alert Manager Container App (optional)
resource "azurerm_container_app" "alertmanager" {
  count                        = var.enable_alertmanager ? 1 : 0
  name                         = "${var.name_prefix}-alertmanager-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.monitoring.id
  resource_group_name          = local.resource_group.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.monitoring.id]
  }

  ingress {
    external_enabled = var.alertmanager_external_access
    target_port      = 9093
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 1
    max_replicas = 2

    container {
      name   = "alertmanager"
      image  = var.alertmanager_image
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name  = "ALERTMANAGER_CONFIG_PATH"
        value = "/etc/alertmanager/alertmanager.yml"
      }

      # Liveness probe
      liveness_probe {
        http_get {
          path = "/-/healthy"
          port = 9093
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }

      # Readiness probe
      readiness_probe {
        http_get {
          path = "/-/ready"
          port = 9093
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }
  }

  tags = var.tags
}

# RBAC assignments for monitoring identity
resource "azurerm_role_assignment" "monitoring_reader" {
  scope                = local.resource_group.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_user_assigned_identity.monitoring.principal_id
}

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = azurerm_storage_account.prometheus.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_user_assigned_identity.monitoring.principal_id
}

# Azure Monitor Private Link Scope (optional for private connectivity)
resource "azurerm_monitor_private_link_scope" "monitoring" {
  count               = var.enable_private_link ? 1 : 0
  name                = "${var.name_prefix}-ampls-${random_string.suffix.result}"
  resource_group_name = local.resource_group.name

  tags = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "law" {
  count               = var.enable_private_link ? 1 : 0
  name                = "${var.name_prefix}-ampls-law"
  resource_group_name = local.resource_group.name
  scope_name          = azurerm_monitor_private_link_scope.monitoring[0].name
  linked_resource_id  = azurerm_log_analytics_workspace.monitoring.id
}

resource "azurerm_monitor_private_link_scoped_service" "ai" {
  count               = var.enable_private_link ? 1 : 0
  name                = "${var.name_prefix}-ampls-ai"
  resource_group_name = local.resource_group.name
  scope_name          = azurerm_monitor_private_link_scope.monitoring[0].name
  linked_resource_id  = azurerm_application_insights.monitoring.id
}
