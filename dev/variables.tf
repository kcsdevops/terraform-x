# Variables for Dev Environment
# Arquivo de variáveis para ambiente de desenvolvimento

# Configurações globais
variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "mvp-flex-dev"
}

variable "location" {
  description = "Localização dos recursos Azure"
  type        = string
  default     = "brazilsouth"
}

variable "environment" {
  description = "Ambiente (dev, homolog, prod)"
  type        = string
  default     = "dev"
}

# SQL Database variables
variable "sql_server_name" {
  description = "Nome do SQL Server"
  type        = string
  default     = "dev-sqlsrv-min"
}

variable "sql_database_name" {
  description = "Nome do SQL Database"
  type        = string
  default     = "dev-sqldb-min"
}

variable "administrator_login" {
  description = "Login do administrador SQL"
  type        = string
  default     = "devadmin"
}

variable "sku_name" {
  description = "SKU do SQL Database"
  type        = string
  default     = "Basic"
}

variable "sku" {
  description = "SKU tier para recursos"
  type        = string
  default     = "Basic"
}

# Network variables
variable "vnet_name" {
  description = "Nome da Virtual Network"
  type        = string
  default     = "dev-vnet-min"
}

variable "address_space" {
  description = "Address space da VNet"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_name" {
  description = "Nome da subnet"
  type        = string
  default     = "dev-subnet-min"
}

variable "address_prefixes" {
  description = "Address prefixes da subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "nsg_name" {
  description = "Nome do Network Security Group"
  type        = string
  default     = "dev-nsg-min"
}

# Storage variables
variable "storage_account_name" {
  description = "Nome da Storage Account"
  type        = string
  default     = "devstgmin"
}

variable "account_tier" {
  description = "Tier da Storage Account"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Tipo de replicação da Storage Account"
  type        = string
  default     = "LRS"
}

# ACR variables
variable "acr_name" {
  description = "Nome do Azure Container Registry"
  type        = string
  default     = "devacrmin"
}

# Tags variable
variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default = {
    environment   = "dev"
    project       = "mvp-flex"
    cost_tier     = "minimal"
    owner         = "time-dev"
    auto_shutdown = "true"
  }
}
