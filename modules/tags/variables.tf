# Variáveis para o módulo de tags corporativas
# Definição de todas as variáveis necessárias para governança

# Variáveis obrigatórias básicas
variable "environment" {
  description = "Ambiente de deployment (dev, homolog, prod)"
  type        = string
  validation {
    condition = contains(["dev", "homolog", "prod"], var.environment)
    error_message = "Environment deve ser: dev, homolog ou prod."
  }
}

variable "owner" {
  description = "Responsável pelo recurso (equipe ou pessoa)"
  type        = string
  default     = "time-devops"
}

variable "resource_name" {
  description = "Nome do recurso para identificação"
  type        = string
}

# Variáveis corporativas obrigatórias
variable "projeto" {
  description = "Nome do projeto corporativo"
  type        = string
  default     = "Financeiro"
}

variable "produto" {
  description = "Nome do produto ou solução"
  type        = string
  default     = "Flex+"
}

variable "centro_custos" {
  description = "Centro de custos para billing e chargeback"
  type        = string
  default     = "Flex-Cost"
}

# Variáveis opcionais para governança
variable "compliance_level" {
  description = "Nível de compliance necessário (LGPD, SOC2, ISO27001)"
  type        = string
  default     = "LGPD"
  validation {
    condition = contains(["LGPD", "SOC2", "ISO27001", "PCI-DSS"], var.compliance_level)
    error_message = "Compliance level deve ser: LGPD, SOC2, ISO27001 ou PCI-DSS."
  }
}

variable "backup_policy" {
  description = "Política de backup aplicável ao recurso"
  type        = string
  default     = "standard"
  validation {
    condition = contains(["none", "basic", "standard", "premium"], var.backup_policy)
    error_message = "Backup policy deve ser: none, basic, standard ou premium."
  }
}

variable "lifecycle_stage" {
  description = "Estágio do ciclo de vida do recurso"
  type        = string
  default     = "active"
  validation {
    condition = contains(["development", "testing", "active", "deprecated", "retired"], var.lifecycle_stage)
    error_message = "Lifecycle stage deve ser: development, testing, active, deprecated ou retired."
  }
}

# Variáveis para customização por ambiente
variable "additional_tags" {
  description = "Tags adicionais específicas do recurso"
  type        = map(string)
  default     = {}
}
