# main.tf - Prometheus Monitoring com nomenclatura corporativa atualizada
# Nova nomenclatura: rg-meuqueridinho-brs-meuquerinho-monitoring-{ambiente}

variable "environment" {
  description = "Ambiente (dev, hml, prd, monitoring)"
  type        = string
  default     = "monitoring"
}

variable "resource_group_name" {
  description = "Nome do Resource Group (será sobrescrito pela nomenclatura corporativa)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Localização Azure"
  type        = string
  default     = "brazilsouth"
}

locals {
  # Nomenclatura corporativa atualizada
  rg_name = var.resource_group_name != "" ? var.resource_group_name : "rg-meuqueridinho-brs-meuquerinho-monitoring-${var.environment}"
  
  # Tags corporativas
  tags = {
    Empresa      = "Meu Queridinho Card"
    Projeto      = "meu-queridinho-card"
    Ambiente     = var.environment
    LocalBrasil  = "Brazil South"
    ManagedBy    = "terraform"
    BusinessUnit = "TI"
    Owner        = "SRE Team"
    Funcao       = "monitoring"
    Purpose      = "prometheus-monitoring"
    CreatedDate  = "2025-08-15"
  }
}

# Resource Group com nomenclatura corporativa
resource "azurerm_resource_group" "monitoring" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# Restante do código do Prometheus mantém a estrutura existente
# mas agora usando a nova nomenclatura para o Resource Group
