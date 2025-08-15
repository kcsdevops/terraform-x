# Configuração MÍNIMA para ambiente de desenvolvimento
# terraform.tfvars com recursos de menor custo possível

# Configurações globais
resource_group_name = "mvp-flex-dev"
location           = "brazilsouth"
environment        = "dev"

# SQL Database - CONFIGURAÇÃO MÍNIMA (menor custo)
sql_server_name     = "dev-sqlsrv-min"
sql_database_name   = "dev-sqldb-min"
administrator_login = "devadmin"
sku_name           = "Basic"  # Menor custo: Basic (5 DTU, 2GB max)

# Tags otimizadas
tags = {
  environment = "dev"
  project     = "mvp-flex"
  cost_tier   = "minimal"
  owner       = "time-dev"
  auto_shutdown = "true"
}

# VNet/Subnet (configuração mínima)
vnet_name        = "dev-vnet-min"
address_space    = ["10.10.0.0/16"]
subnet_name      = "dev-subnet-min"
address_prefixes = ["10.10.1.0/24"]
nsg_name         = "dev-nsg-min"

# Storage - CONFIGURAÇÃO MÍNIMA
storage_account_name = "devstgmin"
account_tier        = "Standard"     # Menor custo
account_replication_type = "LRS"     # Local Redundant Storage (menor custo)

# ACR - CONFIGURAÇÃO MÍNIMA
acr_name = "devacrmin"
sku      = "Basic"  # Menor custo: Basic tier
