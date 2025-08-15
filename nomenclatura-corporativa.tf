# ============================================================================
# NOMENCLATURA CORPORATIVA - MEU QUERIDINHO CARD
# Padrão: rg-empresa-localBrasil-meuquerinho-{nome do recurso}-{ambiente}
# ============================================================================

locals {
  # Componentes fixos da empresa
  empresa = "meuqueridinho"
  local_brasil = "brs"
  projeto = "meuquerinho"
  
  # Definição dos nomes dos Resource Groups por ambiente e função
  resource_groups = {
    # Infraestrutura Principal
    infra_dev = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-infraestrutura-dev"
    infra_hml = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-infraestrutura-hml" 
    infra_prd = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-infraestrutura-prd"
    
    # Aplicações
    app_dev = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-aplicacao-dev"
    app_hml = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-aplicacao-hml"
    app_prd = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-aplicacao-prd"
    
    # Monitoramento
    monitoring = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-monitoramento-central"
    
    # Segurança
    security = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-seguranca-central"
    
    # Rede
    network_dev = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-rede-dev"
    network_hml = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-rede-hml"
    network_prd = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-rede-prd"
    
    # Storage
    storage_dev = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-storage-dev"
    storage_hml = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-storage-hml"
    storage_prd = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-storage-prd"
    
    # Dados
    dados_dev = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-dados-dev"
    dados_hml = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-dados-hml"
    dados_prd = "rg-${local.empresa}-${local.local_brasil}-${local.projeto}-dados-prd"
  }
  
  # Tags corporativas padrão
  tags_corporativas = {
    Empresa      = "Meu Queridinho Card"
    Projeto      = "meu-queridinho-card"
    LocalBrasil  = "Brazil South"
    ManagedBy    = "terraform"
    CreatedDate  = formatdate("YYYY-MM-DD", timestamp())
    BusinessUnit = "TI"
    Owner        = "DevOps Team"
  }
}
