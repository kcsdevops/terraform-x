# main.tf - Configuração PRODUÇÃO com nomenclatura corporativa atualizada  
# Nova nomenclatura: rg-meuqueridinho-brs-meuquerinho-aplicacao-prd

# Resource Group com nova nomenclatura corporativa
resource "azurerm_resource_group" "main" {
  name     = "rg-meuqueridinho-brs-meuquerinho-aplicacao-prd"
  location = "brazilsouth"

  tags = {
    Empresa      = "Meu Queridinho Card"
    Projeto      = "meu-queridinho-card"
    Ambiente     = "prd"
    LocalBrasil  = "Brazil South"
    ManagedBy    = "terraform"
    BusinessUnit = "TI"
    Owner        = "DevOps Team"
    Funcao       = "aplicacao"
    CostTier     = "premium"
    Compliance   = "PCI-DSS"
    CreatedDate  = "2025-08-15"
  }
}
