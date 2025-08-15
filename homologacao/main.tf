# main.tf - Configuração MÍNIMA para Homologação
# Recursos com menor custo possível

module "tags_sql" {
  source        = "../modules/tags"
  environment   = "homolog"
  owner         = "time-homolog"
  resource_name = "sqlsrv"
}

module "sql" {
  source              = "../modules/sql"
  sql_server_name     = "hml-sqlsrv-min"
  sql_database_name   = "hml-sqldb-min"
  resource_group_name = "hml-rg-min"
  location            = "brazilsouth"
  administrator_login = "hmladmin"
  sku_name            = "S0" # Standard S0 - mínimo adequado para homolog
  tags                = module.tags_sql.tags
}
