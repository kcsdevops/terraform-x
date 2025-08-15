# Keycloak Container App Module
# This module deploys Keycloak identity management system on Azure Container Apps
# with full integration to Azure Key Vault for secrets management

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Key Vault for storing all Keycloak secrets
resource "azurerm_key_vault" "keycloak" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enabled_for_deployment          = true
  purge_protection_enabled        = var.enable_purge_protection
  soft_delete_retention_days      = var.soft_delete_retention_days

  network_acls {
    default_action = "Deny"
    ip_rules       = var.key_vault_allowed_ips
    virtual_network_subnet_ids = [
      azurerm_subnet.container_apps.id
    ]
  }

  tags = var.tags
}

# User-assigned managed identity for Container Apps
resource "azurerm_user_assigned_identity" "keycloak" {
  name                = "${var.keycloak_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Key Vault access policy for managed identity
resource "azurerm_key_vault_access_policy" "keycloak_identity" {
  key_vault_id = azurerm_key_vault.keycloak.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.keycloak.principal_id

  key_permissions = [
    "Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore",
    "Decrypt", "Encrypt", "Sign", "Verify", "WrapKey", "UnwrapKey"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Update", "Delete", "Recover", "Backup", "Restore",
    "Import", "ManageContacts", "ManageIssuers"
  ]
}

# Virtual Network for Container Apps
resource "azurerm_virtual_network" "keycloak" {
  name                = "${var.keycloak_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = var.tags
}

# Subnet for Container Apps Environment
resource "azurerm_subnet" "container_apps" {
  name                 = "${var.keycloak_name}-container-apps-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.keycloak.name
  address_prefixes     = [var.container_apps_subnet_cidr]

  delegation {
    name = "Microsoft.App.environments"
    service_delegation {
      name = "Microsoft.App/environments"
    }
  }
}

# Subnet for PostgreSQL Database
resource "azurerm_subnet" "database" {
  name                 = "${var.keycloak_name}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.keycloak.name
  address_prefixes     = [var.database_subnet_cidr]

  delegation {
    name = "Microsoft.DBforPostgreSQL.flexibleServers"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
    }
  }
}

# Log Analytics Workspace for Container Apps Environment
resource "azurerm_log_analytics_workspace" "keycloak" {
  name                = "${var.keycloak_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# PostgreSQL Flexible Server for Keycloak database
resource "azurerm_postgresql_flexible_server" "keycloak" {
  name                   = "${var.keycloak_name}-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgres_version
  delegated_subnet_id    = azurerm_subnet.database.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  administrator_login    = var.postgres_admin_username
  administrator_password = random_password.postgres_password.result
  zone                   = "1"
  storage_mb             = var.postgres_storage_mb
  sku_name               = var.postgres_sku

  backup_retention_days        = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

# Private DNS Zone for PostgreSQL
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.keycloak_name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${var.keycloak_name}-postgres-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.keycloak.id
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
}

# Random password for PostgreSQL
resource "random_password" "postgres_password" {
  length  = 32
  special = true
}

# Store PostgreSQL password in Key Vault
resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "keycloak-db-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.keycloak.id

  depends_on = [azurerm_key_vault_access_policy.keycloak_identity]
}

# Keycloak database
resource "azurerm_postgresql_flexible_server_database" "keycloak" {
  name      = var.keycloak_database_name
  server_id = azurerm_postgresql_flexible_server.keycloak.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Container Apps Environment
resource "azurerm_container_app_environment" "keycloak" {
  name                       = "${var.keycloak_name}-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.keycloak.id
  infrastructure_subnet_id   = azurerm_subnet.container_apps.id

  tags = var.tags
}

# Keycloak admin password
resource "random_password" "keycloak_admin" {
  length  = 16
  special = true
}

# Store Keycloak admin password in Key Vault
resource "azurerm_key_vault_secret" "keycloak_admin_password" {
  name         = "keycloak-admin-password"
  value        = random_password.keycloak_admin.result
  key_vault_id = azurerm_key_vault.keycloak.id

  depends_on = [azurerm_key_vault_access_policy.keycloak_identity]
}

# Keycloak Container App
resource "azurerm_container_app" "keycloak" {
  name                         = var.keycloak_name
  container_app_environment_id = azurerm_container_app_environment.keycloak.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.keycloak.id]
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "keycloak"
      image  = var.keycloak_image
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "KEYCLOAK_ADMIN"
        value = var.keycloak_admin_username
      }

      env {
        name        = "KEYCLOAK_ADMIN_PASSWORD"
        secret_name = "keycloak-admin-password"
      }

      env {
        name  = "KC_DB"
        value = "postgres"
      }

      env {
        name  = "KC_DB_URL"
        value = "jdbc:postgresql://${azurerm_postgresql_flexible_server.keycloak.fqdn}:5432/${azurerm_postgresql_flexible_server_database.keycloak.name}"
      }

      env {
        name  = "KC_DB_USERNAME"
        value = var.postgres_admin_username
      }

      env {
        name        = "KC_DB_PASSWORD"
        secret_name = "keycloak-db-password"
      }

      env {
        name  = "KC_HOSTNAME"
        value = var.keycloak_hostname
      }

      env {
        name  = "KC_HOSTNAME_STRICT"
        value = "false"
      }

      env {
        name  = "KC_HTTP_ENABLED"
        value = "true"
      }

      env {
        name  = "KC_PROXY"
        value = "edge"
      }

      env {
        name  = "KC_HEALTH_ENABLED"
        value = "true"
      }

      env {
        name  = "KC_METRICS_ENABLED"
        value = "true"
      }

      args = ["start", "--optimized"]

      liveness_probe {
        path              = "/health/live"
        port              = 8080
        transport         = "HTTP"
        interval_seconds  = 30
        timeout_seconds   = 10
        failure_threshold = 3
      }

      readiness_probe {
        path              = "/health/ready"
        port              = 8080
        transport         = "HTTP"
        interval_seconds  = 10
        timeout_seconds   = 5
        failure_threshold = 3
      }

      startup_probe {
        path              = "/health/started"
        port              = 8080
        transport         = "HTTP"
        interval_seconds  = 30
        timeout_seconds   = 10
        failure_threshold = 10
      }
    }
  }

  secret {
    name  = "keycloak-admin-password"
    value = random_password.keycloak_admin.result
  }

  secret {
    name  = "keycloak-db-password"
    value = random_password.postgres_password.result
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 8080
    transport                  = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_postgresql_flexible_server.keycloak,
    azurerm_postgresql_flexible_server_database.keycloak,
    azurerm_key_vault_secret.postgres_password,
    azurerm_key_vault_secret.keycloak_admin_password
  ]
}

# Additional secrets for system integrations
resource "azurerm_key_vault_secret" "system_secrets" {
  for_each = var.system_secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.keycloak.id

  depends_on = [azurerm_key_vault_access_policy.keycloak_identity]

  tags = merge(var.tags, {
    system = "keycloak"
    type   = "integration"
  })
}
