# main.tf - Configuração MÍNIMA para Desenvolvimento
# Recursos com menor custo possível

module "tags_sql" {
  source        = "../modules/tags"
  environment   = "dev"
  owner         = "time-dev"
  resource_name = "sqlsrv"
}

module "sql" {
  source              = "../modules/sql"
  sql_server_name     = "dev-sqlsrv-min"
  sql_database_name   = "dev-sqldb-min"
  resource_group_name = "dev-rg-min"
  location            = "brazilsouth"
  administrator_login = "devadmin"
  sku_name            = "Basic" # Basic tier - menor custo possível
  tags                = module.tags_sql.tags
}
