# main.tf - Configuração PRODUÇÃO com tags corporativas atualizadas
# Recursos enterprise com alta disponibilidade e performance

module "tags_sql" {
  source = "../modules/tags"
  
  # Tags básicas
  environment   = "prod"
  owner         = "time-producao"
  resource_name = "sqlsrv"
  
  # Tags corporativas
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  # Tags de governança PRODUÇÃO
  compliance_level = "SOC2"
  backup_policy   = "premium"
  lifecycle_stage = "active"
  
  # Tags adicionais específicas
  additional_tags = {
    cost_center_code    = "FC-003-PRD"
    budget_owner        = "gerencia-financeiro"
    auto_shutdown       = "disabled"
    environment_type    = "production"
    sla_tier           = "premium"
    disaster_recovery  = "enabled"
    high_availability  = "zone_redundant"
    monitoring_level   = "advanced"
  }
}

module "sql" {
  source = "../modules/sql"
  
  # Configuração enterprise
  sql_server_name     = "prd-sqlsrv-enterprise"
  sql_database_name   = "prd-sqldb-enterprise"
  resource_group_name = "prd-rg-enterprise"
  location            = "brazilsouth"
  administrator_login = "prdadmin"
  sku_name           = "P1" # Premium P1 - enterprise grade
  
  # Tags com governança corporativa
  tags = module.tags_sql.tags_with_additional
}

# Módulos adicionais para produção
module "tags_keycloak" {
  source = "../modules/tags"
  
  environment   = "prod"
  owner         = "time-producao"
  resource_name = "keycloak"
  
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  compliance_level = "SOC2"
  backup_policy   = "premium"
  lifecycle_stage = "active"
  
  additional_tags = {
    cost_center_code = "FC-003-PRD-IDM"
    service_type     = "identity_management"
    sla_tier        = "premium"
  }
}

module "tags_monitoring" {
  source = "../modules/tags"
  
  environment   = "prod"
  owner         = "time-producao" 
  resource_name = "monitoring"
  
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  compliance_level = "SOC2"
  backup_policy   = "premium"
  lifecycle_stage = "active"
  
  additional_tags = {
    cost_center_code = "FC-003-PRD-MON"
    service_type     = "observability"
    sla_tier        = "premium"
  }
}

# Output consolidado das informações de deployment
output "deployment_info" {
  description = "Informações consolidadas do deployment PRODUÇÃO"
  value = {
    environment      = "prod"
    deploy_date      = module.tags_sql.deploy_info.date
    deploy_time      = module.tags_sql.deploy_info.timestamp
    resource_groups  = {
      sql        = module.tags_sql.resource_group_name
      keycloak   = module.tags_keycloak.resource_group_name
      monitoring = module.tags_monitoring.resource_group_name
    }
    cost_estimate    = "R$ 3000/mês"
    billing_tags     = module.tags_sql.billing_tags
    compliance_level = "SOC2"
  }
}

# Output das tags para auditoria
output "applied_tags_summary" {
  description = "Resumo das tags aplicadas em todos os recursos PRODUÇÃO"
  value = {
    sql_tags        = module.tags_sql.tags_with_additional
    keycloak_tags   = module.tags_keycloak.tags_with_additional
    monitoring_tags = module.tags_monitoring.tags_with_additional
  }
  sensitive = false
}

# Output específico para compliance e auditoria
output "compliance_summary" {
  description = "Resumo de compliance para auditoria"
  value = {
    compliance_level  = "SOC2"
    backup_policies   = ["premium"]
    lifecycle_stages  = ["active"]
    cost_centers     = ["FC-003-PRD", "FC-003-PRD-IDM", "FC-003-PRD-MON"]
    sla_requirements = "premium"
    monitoring_level = "advanced"
  }
}
