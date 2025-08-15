# main.tf - Configuração HOMOLOGAÇÃO com nomenclatura corporativa atualizada
# Nova nomenclatura: rg-meuqueridinho-brs-meuquerinho-aplicacao-hml

# Resource Group com nova nomenclatura corporativa
resource "azurerm_resource_group" "main" {
  name     = "rg-meuqueridinho-brs-meuquerinho-aplicacao-hml"
  location = "brazilsouth"

  tags = {
    Empresa      = "Meu Queridinho Card"
    Projeto      = "meu-queridinho-card"
    Ambiente     = "hml"
    LocalBrasil  = "Brazil South"
    ManagedBy    = "terraform"
    BusinessUnit = "TI"
    Owner        = "DevOps Team"
    Funcao       = "aplicacao"
    CostTier     = "standard"
    CreatedDate  = "2025-08-15"
  }
}
