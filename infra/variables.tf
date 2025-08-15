// variables.tf - Variáveis para parametrização

variable "resource_group_name" {
  description = "Nome do Resource Group principal"
  type        = string
  default     = "fin-proj-rg"
}

variable "location" {
  description = "Região do Azure para os recursos"
  type        = string
  default     = "eastus"
}

// Adicione outras variáveis conforme necessário para parametrizar nomes, tamanhos, etc.
