# main.tf - Configuração HOMOLOGAÇÃO com tags corporativas atualizadas
# Recursos intermediários para validação e testes

module "tags_sql" {
  source = "../modules/tags"
  
  # Tags básicas
  environment   = "homolog"
  owner         = "time-homolog"
  resource_name = "sqlsrv"
  
  # Tags corporativas
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  # Tags de governança HOMOLOG
  compliance_level = "LGPD"
  backup_policy   = "standard"
  lifecycle_stage = "testing"
  
  # Tags adicionais específicas
  additional_tags = {
    cost_center_code = "FC-002-HML"
    budget_owner     = "gerencia-financeiro"
    auto_shutdown    = "scheduled"
    environment_type = "homologation"
    test_scope       = "integration"
    performance_tier = "standard"
  }
}

module "sql" {
  source = "../modules/sql"
  
  # Configuração intermediária
  sql_server_name     = "hml-sqlsrv-min"
  sql_database_name   = "hml-sqldb-min"
  resource_group_name = "hml-rg-min"
  location            = "brazilsouth"
  administrator_login = "hmladmin"
  sku_name           = "S0" # Standard S0 - mínimo adequado para homolog
  
  # Tags com governança corporativa
  tags = module.tags_sql.tags_with_additional
}

# Output das informações de deployment
output "deployment_info" {
  description = "Informações do deployment HOMOLOG"
  value = {
    environment    = "homolog"
    deploy_date    = module.tags_sql.deploy_info.date
    deploy_time    = module.tags_sql.deploy_info.timestamp
    resource_group = module.tags_sql.resource_group_name
    cost_estimate  = "R$ 800/mês"
    billing_tags   = module.tags_sql.billing_tags
  }
}

# Output das tags para auditoria
output "applied_tags" {
  description = "Tags aplicadas no ambiente HOMOLOG"
  value       = module.tags_sql.tags_with_additional
  sensitive   = false
}

# Output específico para compliance
output "compliance_info" {
  description = "Informações de compliance do ambiente"
  value       = module.tags_sql.compliance_tags
}
