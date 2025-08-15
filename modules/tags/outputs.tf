# Outputs do módulo de tags para uso em outros módulos
# Fornece tags formatadas e informações de deployment

output "tags" {
  description = "Todas as tags padrão corporativas para aplicar aos recursos"
  value       = local.tags
}

output "tags_with_additional" {
  description = "Tags padrão combinadas com tags adicionais"
  value       = merge(local.tags, var.additional_tags)
}

output "resource_group_name" {
  description = "Nome padrão para o Resource Group baseado nas convenções"
  value       = local.tags.rg_pattern
}

output "deploy_info" {
  description = "Informações do deployment atual"
  value = {
    date      = local.deploy_date
    timestamp = local.deploy_timestamp
    terraform = "true"
  }
}

output "billing_tags" {
  description = "Tags específicas para controle de custos e billing"
  value = {
    projeto       = local.tags.projeto
    produto       = local.tags.produto
    centro_custos = local.tags.centro_custos
    environment   = local.tags.environment
    owner         = local.tags.owner
  }
}

output "compliance_tags" {
  description = "Tags relacionadas a compliance e governança"
  value = {
    compliance    = local.tags.compliance
    backup_policy = local.tags.backup_policy
    lifecycle     = local.tags.lifecycle
    managed_by    = local.tags.managed_by
  }
}

output "formatted_tags_json" {
  description = "Tags formatadas em JSON para documentação"
  value       = jsonencode(local.tags)
}
