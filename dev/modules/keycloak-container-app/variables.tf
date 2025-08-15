# Keycloak Container App Module Variables

# General Configuration
variable "keycloak_name" {
  description = "Name prefix for Keycloak resources"
  type        = string
  default     = "keycloak"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "Brazil South"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    project     = "keycloak-identity"
    environment = "production"
    managed_by  = "terraform"
  }
}

# Key Vault Configuration
variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "key_vault_sku" {
  description = "SKU for the Key Vault"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "enable_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain deleted keys/secrets"
  type        = number
  default     = 90
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "key_vault_allowed_ips" {
  description = "List of IP addresses allowed to access Key Vault"
  type        = list(string)
  default     = []
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.100.0.0/16"
}

variable "container_apps_subnet_cidr" {
  description = "CIDR block for Container Apps subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "database_subnet_cidr" {
  description = "CIDR block for database subnet"
  type        = string
  default     = "10.100.2.0/24"
}

variable "admin_allowed_cidr" {
  description = "CIDR block allowed to access Keycloak admin interface"
  type        = string
  default     = "0.0.0.0/0"
}

# Container Configuration
variable "keycloak_image" {
  description = "Keycloak container image"
  type        = string
  default     = "quay.io/keycloak/keycloak:latest"
}

variable "container_cpu" {
  description = "CPU allocation for Keycloak container"
  type        = number
  default     = 1.0
}

variable "container_memory" {
  description = "Memory allocation for Keycloak container"
  type        = string
  default     = "2Gi"
}

variable "min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 3
}

# Keycloak Configuration
variable "keycloak_admin_username" {
  description = "Keycloak admin username"
  type        = string
  default     = "admin"
}

variable "keycloak_hostname" {
  description = "Hostname for Keycloak"
  type        = string
  default     = ""
}

variable "keycloak_database_name" {
  description = "Name of the Keycloak database"
  type        = string
  default     = "keycloak"
}

# PostgreSQL Configuration
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "postgres_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  default     = "keycloakadmin"
}

variable "postgres_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "postgres_sku" {
  description = "SKU for PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "postgres_geo_redundant_backup" {
  description = "Enable geo-redundant backup"
  type        = bool
  default     = false
}

variable "postgres_high_availability_mode" {
  description = "High availability mode for PostgreSQL"
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "ZoneRedundant", "SameZone"], var.postgres_high_availability_mode)
    error_message = "High availability mode must be 'Disabled', 'ZoneRedundant', or 'SameZone'."
  }
}

variable "postgres_maintenance_day" {
  description = "Day of week for maintenance window"
  type        = number
  default     = 0
}

variable "postgres_maintenance_hour" {
  description = "Hour for maintenance window"
  type        = number
  default     = 2
}

variable "postgres_maintenance_minute" {
  description = "Minute for maintenance window"
  type        = number
  default     = 0
}

# Monitoring Configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

# System Integration Secrets
variable "system_secrets" {
  description = "Map of additional secrets for system integrations"
  type        = map(string)
  default     = {}
  sensitive   = true
}
