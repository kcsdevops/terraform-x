# Configuração MÍNIMA para ambiente de homologação
# terraform.tfvars com recursos de menor custo possível

# Configurações globais
resource_group_name = "mvp-flex-homolog"
location            = "brazilsouth"
environment         = "homolog"

# SQL Database - CONFIGURAÇÃO MÍNIMA (pouco mais que dev)
sql_server_name     = "hml-sqlsrv-min"
sql_database_name   = "hml-sqldb-min"
administrator_login = "hmladmin"
sku_name            = "S0" # Standard S0 (10 DTU, 250GB max) - mínimo para homolog

# Tags otimizadas
tags = {
  environment   = "homolog"
  project       = "mvp-flex"
  cost_tier     = "minimal"
  owner         = "time-homolog"
  auto_shutdown = "true"
  testing       = "pre-prod"
}

# VNet/Subnet (configuração mínima diferente do dev)
vnet_name        = "hml-vnet-min"
address_space    = ["10.20.0.0/16"]
subnet_name      = "hml-subnet-min"
address_prefixes = ["10.20.1.0/24"]
nsg_name         = "hml-nsg-min"

# Storage - CONFIGURAÇÃO MÍNIMA
storage_account_name     = "hmlstgmin"
account_tier             = "Standard" # Menor custo
account_replication_type = "LRS"      # Local Redundant Storage (menor custo)

# ACR - CONFIGURAÇÃO MÍNIMA
acr_name = "hmlacrmin"
sku      = "Basic" # Menor custo: Basic tier
