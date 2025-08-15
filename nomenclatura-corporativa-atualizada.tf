# ============================================================================
# NOMENCLATURA CORPORATIVA ATUALIZADA - MEU QUERIDINHO CARD
# Padrão: rg-meuqueridinho-brs-meuquerinho-{nome do recurso}-{ambiente}
# ============================================================================

locals {
  # Componentes fixos da empresa
  empresa = "meuqueridinho"
  local_brasil = "brs"
  projeto_core = "meuquerinho"
  
  # Nomenclatura para Resource Groups seguindo o padrão solicitado
  resource_groups_nomenclatura = {
    # Ambientes de Aplicação
    dev        = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-aplicacao-dev"
    hml        = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-aplicacao-hml"
    prd        = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-aplicacao-prd"
    
    # Infraestrutura Compartilhada
    infra      = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-infra-shared"
    network    = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-network-shared"
    storage    = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-storage-shared"
    
    # Monitoramento e Observabilidade
    monitoring = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-monitoring-central"
    logs       = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-logs-central"
    metrics    = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-metrics-central"
    
    # Segurança e Compliance
    security   = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-security-central"
    keyvault   = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-keyvault-shared"
    
    # APIs e Microserviços
    apis       = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-apis-shared"
    gateway    = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-gateway-shared"
    
    # Bancos de Dados
    database   = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-database-shared"
    cache      = "rg-${local.empresa}-${local.local_brasil}-${local.projeto_core}-cache-shared"
  }
  
  # Tags corporativas padronizadas
  tags_corporativas = {
    Empresa       = "Meu Queridinho Card"
    Projeto       = "meu-queridinho-card"
    LocalBrasil   = "Brazil South"
    ManagedBy     = "terraform"
    BusinessUnit  = "TI"
    CreatedDate   = "2025-08-15"
    CostCenter    = "TI-001"
    DataClass     = "Internal"
  }
  
  # Tags específicas por ambiente
  ambiente_tags = {
    dev = merge(local.tags_corporativas, {
      Ambiente    = "dev"
      CostTier    = "minimal"
      Owner       = "DevOps Team"
      Purpose     = "development"
    })
    
    hml = merge(local.tags_corporativas, {
      Ambiente    = "hml"
      CostTier    = "standard"
      Owner       = "QA Team"
      Purpose     = "homologation"
    })
    
    prd = merge(local.tags_corporativas, {
      Ambiente    = "prd"
      CostTier    = "premium"
      Owner       = "Operations Team"
      Purpose     = "production"
      Compliance  = "PCI-DSS"
    })
    
    shared = merge(local.tags_corporativas, {
      Ambiente    = "shared"
      CostTier    = "shared"
      Owner       = "Infrastructure Team"
      Purpose     = "shared-services"
    })
    
    monitoring = merge(local.tags_corporativas, {
      Ambiente    = "monitoring"
      CostTier    = "operational"
      Owner       = "SRE Team"
      Purpose     = "observability"
    })
  }
}

# Outputs para usar em outros módulos
output "resource_groups" {
  description = "Nomenclatura atualizada dos Resource Groups"
  value = local.resource_groups_nomenclatura
}

output "ambiente_atual" {
  description = "Tags do ambiente atual baseado no workspace"
  value = lookup(local.ambiente_tags, terraform.workspace, local.tags_corporativas)
}

# Exemplo de uso:
output "exemplo_uso" {
  description = "Exemplo de como usar a nomenclatura"
  value = {
    "Ambiente DEV"        = local.resource_groups_nomenclatura.dev
    "Ambiente HML"        = local.resource_groups_nomenclatura.hml  
    "Ambiente PRD"        = local.resource_groups_nomenclatura.prd
    "Infra Compartilhada" = local.resource_groups_nomenclatura.infra
    "Monitoramento"       = local.resource_groups_nomenclatura.monitoring
  }
}
