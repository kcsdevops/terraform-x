module "tags_sql" {
  source        = "../modules/tags"
  environment   = "producao"
  owner         = "time-prd"
  resource_name = "sqlsrv"
}

module "sql" {
  source              = "../modules/sql"
  sql_server_name     = "prd-sqlsrv"
  sql_database_name   = "prd-sqldb"
  resource_group_name = "prd-rg"
  location            = "brazilsouth"
  administrator_login = "prdadmin"
  sku_name            = "S2"
  tags                = module.tags_sql.tags
}

output "az_version" {
  value = az - -version
}
