# main.tf - Configuração INFRAESTRUTURA com nomenclatura corporativa atualizada
# Nova nomenclatura: rg-meuqueridinho-brs-meuquerinho-infra-shared

# Resource Group com nova nomenclatura corporativa
resource "azurerm_resource_group" "main" {
  name     = "rg-meuqueridinho-brs-meuquerinho-infra-shared"
  location = "brazilsouth"

  tags = {
    Empresa      = "Meu Queridinho Card"
    Projeto      = "meu-queridinho-card"
    Ambiente     = "shared"
    LocalBrasil  = "Brazil South"
    ManagedBy    = "terraform"
    BusinessUnit = "TI"
    Owner        = "Infrastructure Team"
    Funcao       = "infra"
    CostTier     = "shared"
    Purpose      = "shared-infrastructure"
    CreatedDate  = "2025-08-15"
  }
}
