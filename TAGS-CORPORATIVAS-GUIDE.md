# TAGS CORPORATIVAS - GOVERNANCE & COMPLIANCE

## VISÃO GERAL

Este documento define o padrão de tags corporativas implementado na infraestrutura Azure para governança, controle de custos e compliance.

## TAGS OBRIGATÓRIAS

### Tags Básicas de Identificação
```hcl
environment     = "dev|homolog|prod"        # Ambiente de deployment
owner          = "time-devops"              # Responsável pelo recurso
resource       = "sqlsrv|keycloak|monitor"  # Nome do recurso
```

### Tags Corporativas (NOVAS)
```hcl
projeto        = "Financeiro"               # Projeto corporativo
produto        = "Flex+"                    # Nome do produto/solução
centro_custos  = "Flex-Cost"               # Centro de custos para billing
```

### Tags de Rastreabilidade Automáticas
```hcl
data_inicio    = "2024-08-15"              # Data do deploy (automática)
deployed_at    = "2024-08-15T10:30:00Z"    # Timestamp completo
terraform      = "true"                    # Indica recurso gerenciado pelo Terraform
managed_by     = "terraform"               # Ferramenta de gestão
```

## TAGS POR AMBIENTE

### Ambiente DEV
```hcl
module "tags_sql" {
  source = "../modules/tags"
  
  # Básicas
  environment   = "dev"
  owner         = "time-dev"
  resource_name = "sqlsrv"
  
  # Corporativas
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  # Governança DEV
  compliance_level = "LGPD"
  backup_policy   = "basic"
  lifecycle_stage = "development"
  
  # Específicas DEV
  additional_tags = {
    cost_center_code = "FC-001-DEV"
    budget_owner     = "gerencia-financeiro"
    auto_shutdown    = "enabled"
    environment_type = "development"
  }
}
```

### Ambiente HOMOLOG
```hcl
module "tags_sql" {
  source = "../modules/tags"
  
  # Básicas
  environment   = "homolog"
  owner         = "time-homolog"
  resource_name = "sqlsrv"
  
  # Corporativas
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  # Governança HOMOLOG
  compliance_level = "LGPD"
  backup_policy   = "standard"
  lifecycle_stage = "testing"
  
  # Específicas HOMOLOG
  additional_tags = {
    cost_center_code = "FC-002-HML"
    budget_owner     = "gerencia-financeiro"
    auto_shutdown    = "scheduled"
    environment_type = "homologation"
    test_scope       = "integration"
    performance_tier = "standard"
  }
}
```

### Ambiente PRODUÇÃO
```hcl
module "tags_sql" {
  source = "../modules/tags"
  
  # Básicas
  environment   = "prod"
  owner         = "time-producao"
  resource_name = "sqlsrv"
  
  # Corporativas
  projeto       = "Financeiro"
  produto       = "Flex+"
  centro_custos = "Flex-Cost"
  
  # Governança PRODUÇÃO
  compliance_level = "SOC2"
  backup_policy   = "premium"
  lifecycle_stage = "active"
  
  # Específicas PRODUÇÃO
  additional_tags = {
    cost_center_code    = "FC-003-PRD"
    budget_owner        = "gerencia-financeiro"
    auto_shutdown       = "disabled"
    environment_type    = "production"
    sla_tier           = "premium"
    disaster_recovery  = "enabled"
    high_availability  = "zone_redundant"
    monitoring_level   = "advanced"
  }
}
```

## ESTRUTURA DE CENTRO DE CUSTOS

### Códigos Padronizados
```
FC-001-DEV    = Flex-Cost Desenvolvimento
FC-002-HML    = Flex-Cost Homologação  
FC-003-PRD    = Flex-Cost Produção

Sufixos por serviço:
-IDM  = Identity Management (Keycloak)
-MON  = Monitoring (Prometheus)
-DB   = Databases
-NET  = Networking
-STG  = Storage
```

## COMPLIANCE E GOVERNANÇA

### Níveis de Compliance
- **DEV/HOMOLOG**: LGPD (Lei Geral de Proteção de Dados)
- **PRODUÇÃO**: SOC2 (Service Organization Control 2)

### Políticas de Backup
- **DEV**: basic (7 dias)
- **HOMOLOG**: standard (30 dias)
- **PRODUÇÃO**: premium (90 dias + LTR)

### Estágios do Ciclo de Vida
- **development**: Recursos em desenvolvimento
- **testing**: Recursos em fase de testes
- **active**: Recursos em produção ativa
- **deprecated**: Recursos marcados para descontinuação
- **retired**: Recursos desativados

## AUTOMATIZAÇÃO DE DATA

### Variáveis Automáticas
O módulo de tags utiliza funções do Terraform para capturar automaticamente:

```hcl
locals {
  deploy_date = formatdate("YYYY-MM-DD", timestamp())
  deploy_timestamp = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
}
```

### Benefícios
- **Rastreabilidade**: Saber quando cada recurso foi criado/atualizado
- **Auditoria**: Timeline completa de mudanças
- **Compliance**: Evidências para auditorias
- **Troubleshooting**: Correlacionar problemas com deployments

## CONTROLE DE CUSTOS

### Tags para Billing
```hcl
projeto       = "Financeiro"     # Projeto para charge
produto       = "Flex+"          # Produto específico
centro_custos = "Flex-Cost"      # Centro de custos principal
owner         = "time-xxx"       # Responsável pelos custos
```

### Estimativas por Ambiente
- **DEV**: R$ 200/mês (FC-001-DEV)
- **HOMOLOG**: R$ 800/mês (FC-002-HML)  
- **PRODUÇÃO**: R$ 3000/mês (FC-003-PRD)

## USO NOS RECURSOS

### Aplicação das Tags
```hcl
# Exemplo de uso em um recurso
resource "azurerm_sql_server" "main" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location           = var.location
  
  # Tags corporativas aplicadas
  tags = var.tags  # Vem do módulo de tags
}
```

### Output de Auditoria
```hcl
output "applied_tags" {
  description = "Tags aplicadas para auditoria"
  value       = module.tags_sql.tags_with_additional
  sensitive   = false
}
```

## VALIDAÇÕES

### Validações Implementadas
- **environment**: Deve ser "dev", "homolog" ou "prod"
- **compliance_level**: LGPD, SOC2, ISO27001 ou PCI-DSS
- **backup_policy**: none, basic, standard ou premium
- **lifecycle_stage**: development, testing, active, deprecated, retired

### Exemplo de Validação
```hcl
variable "environment" {
  description = "Ambiente de deployment"
  type        = string
  validation {
    condition = contains(["dev", "homolog", "prod"], var.environment)
    error_message = "Environment deve ser: dev, homolog ou prod."
  }
}
```

## BENEFÍCIOS IMPLEMENTADOS

### Governança
- ✅ **Padronização**: Tags consistentes em todos os recursos
- ✅ **Rastreabilidade**: Data e hora de cada deploy
- ✅ **Ownership**: Responsáveis claros por recurso
- ✅ **Compliance**: Níveis de compliance definidos

### Financeiro
- ✅ **Chargeback**: Centro de custos por ambiente/serviço
- ✅ **Budget Control**: Códigos para controle orçamentário
- ✅ **Cost Optimization**: Auto-shutdown em dev/homolog
- ✅ **Billing Analysis**: Tags para relatórios detalhados

### Operacional
- ✅ **Lifecycle Management**: Controle do ciclo de vida
- ✅ **Backup Policies**: Políticas automatizadas
- ✅ **Environment Isolation**: Separação clara de ambientes
- ✅ **Monitoring**: Níveis de monitoramento por ambiente

**TAGS CORPORATIVAS IMPLEMENTADAS COM GOVERNANÇA COMPLETA E CONTROLE DE CUSTOS AUTOMATIZADO**
