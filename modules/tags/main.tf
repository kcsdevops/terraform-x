# Módulo para gerar tags padrão para recursos Azure
# Inclui tags corporativas para governança e controle de custos

locals {
  # Data atual para tracking de deploy
  deploy_date = formatdate("YYYY-MM-DD", timestamp())
  deploy_timestamp = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())

  # Tags padrão corporativas
  tags = {
    # Tags de ambiente e identificação
    environment     = var.environment
    owner          = var.owner
    resource       = var.resource_name
    rg_pattern     = "RG-MEURH360-${var.resource_name}-${upper(var.environment)}"

    # Tags corporativas adicionadas
    projeto        = var.projeto
    produto        = var.produto
    data_inicio    = local.deploy_date
    centro_custos  = var.centro_custos

    # Tags de rastreabilidade
    deployed_at    = local.deploy_timestamp
    terraform      = "true"
    managed_by     = "terraform"

    # Tags de compliance
    compliance     = var.compliance_level
    backup_policy  = var.backup_policy

    # Tag de ciclo de vida
    lifecycle      = var.lifecycle_stage
  }
}
