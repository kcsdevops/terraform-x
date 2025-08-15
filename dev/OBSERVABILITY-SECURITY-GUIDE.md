# Observabilidade e Cyber Security - Estrutura SOC

## Visão Geral

Esta estrutura implementa uma solução completa de **Observabilidade** e **Cyber Security** com foco em SOC (Security Operations Center) para o projeto Flex+ Financeiro.

## Estrutura de Pastas

`
modules/
├── observability/
│   ├── prometheus-monitoring/    # Stack Prometheus + Grafana + APM
│   ├── grafana-dashboards/      # Dashboards personalizados
│   └── log-analytics/           # Centralização de logs
│
└── cyber-security/
    ├── soc-dashboard/           # Dashboard SOC principal
    ├── security-alerts/         # Alertas de segurança
    └── compliance-monitoring/   # Monitoramento LGPD/Compliance
`

## Módulos de Observabilidade

### 1. Prometheus Monitoring
- **Stack completo**: Prometheus + Grafana + Node Exporter + OpenTelemetry
- **APM integrado**: Application Performance Monitoring
- **Sidecars**: Node Exporter para métricas de sistema
- **Armazenamento**: Persistent volumes para dados históricos

### 2. Grafana Dashboards
- **Dashboard de Infraestrutura**: CPU, Memória, Rede
- **Dashboard de Aplicação**: Requests, Response Time, Error Rate
- **Dashboard de Negócio**: Métricas do Flex+ (transações, volume financeiro)

### 3. Log Analytics
- **Workspace centralizado**: Todos os logs em um local
- **Application Insights**: Telemetria de aplicações
- **Queries salvas**: Consultas pré-definidas para análise
- **Retenção configurável**: 30 dias para dev, mais para prod

## Módulos de Cyber Security

### 1. SOC Dashboard
- **Dashboard principal**: Visão geral de segurança
- **Alertas de segurança**: Últimas 24h
- **Tentativas de login falhadas**: Monitoramento em tempo real
- **Top IPs atacantes**: Ranking de fontes de ameaças
- **Mudanças de recursos**: Auditoria de alterações
- **Dashboard LGPD**: Compliance e governança

### 2. Security Alerts
- **Tentativas de login falhadas**: > 5 tentativas em 5min
- **Mudanças críticas**: KeyVault, NSG, Role Assignments
- **Acessos suspeitos**: Login de múltiplos países
- **Violações de NSG**: > 100 conexões negadas por IP
- **Action Groups**: Notificações por email/SMS

### 3. Compliance Monitoring
- **Políticas LGPD**: Definições customizadas
- **Auditoria de acesso**: Trilha completa de acessos
- **Status de criptografia**: Monitoramento contínuo
- **Key Vault dedicado**: Chaves de compliance
- **Security Center**: Padrão habilitado

## Métricas e Alertas de Segurança

### Alertas Críticos (Severity 1)
- Mudanças em recursos críticos (KeyVault, NSG, RBAC)
- Falhas de autenticação de serviços críticos
- Violações de políticas de compliance

### Alertas Importantes (Severity 2)
- > 5 tentativas de login falhadas em 5min
- Acessos de múltiplos países em 1h
- > 100 conexões negadas por IP em 5min
- Mudanças não autorizadas em configurações

### Alertas Informativos (Severity 3)
- Novos usuários criados
- Mudanças de permissões
- Acessos fora do horário comercial

## Dashboards SOC

### Dashboard Principal
- **Security Alerts**: Alertas das últimas 24h por severidade
- **Failed Logins**: Gráfico temporal de tentativas falhadas
- **Attack Sources**: Top 10 IPs com mais tentativas
- **Resource Changes**: Timeline de mudanças em recursos
- **NSG Events**: Conexões negadas por NSGs

### Dashboard de Compliance
- **LGPD Score**: Pontuação de compliance (0-100)
- **Data Access Logs**: Auditoria de acessos a dados
- **Encryption Status**: Status de criptografia por recurso
- **Policy Violations**: Violações de políticas

## Configuração por Ambiente

### Development
- Retenção: 30 dias
- Alertas: Reduzidos
- Recursos: Mínimos (Basic tier)
- Monitoramento: Essencial

### Homologação
- Retenção: 90 dias
- Alertas: Completos
- Recursos: Standard tier
- Monitoramento: Completo

### Produção
- Retenção: 365 dias
- Alertas: Máximos
- Recursos: Premium tier
- Monitoramento: Enterprise

## Comandos de Acesso

### Grafana
`ash
# Obter senha do Grafana
az keyvault secret show --vault-name <vault-name> --name grafana-admin-password --query value -o tsv

# Acessar Grafana
# URL fornecida no output do Terraform
`

### Prometheus
`ash
# Verificar saúde do Prometheus
curl <prometheus-url>/-/healthy

# Ver targets
curl <prometheus-url>/targets
`

### Logs e Alertas
`ash
# Ver logs de segurança
az monitor activity-log list --resource-group <rg-name> --max-events 50

# Relatório de compliance
az policy state list --resource-group <rg-name>

# Ver logs do container
az containerapp logs show --name <app-name> --resource-group <rg-name>
`

## Custos Estimados

### Development
- Log Analytics: R\$ 50/mês
- Container Apps: R\$ 100/mês
- Storage: R\$ 20/mês
- **Total**: ~R\$ 170/mês

### Produção
- Log Analytics: R\$ 500/mês
- Container Apps: R\$ 800/mês
- Storage: R\$ 200/mês
- Security Center: R\$ 300/mês
- **Total**: ~R\$ 1.800/mês

## Tags Corporativas

Todos os recursos incluem as tags corporativas:
- **projeto**: Financeiro
- **produto**: Flex+
- **centro_custos**: Flex-Cost
- **data_inicio**: Data do deploy (automática)
- **compliance_level**: LGPD
- **Component**: Observability/Security
- **Service**: Específico do módulo

## Integração com Aplicações

### Instrumentação
`yaml
# Application Insights para .NET
ApplicationInsights:
  ConnectionString: "<connection-string>"

# Prometheus metrics endpoint
/metrics

# Health check endpoint
/health
`

### Logs Estruturados
`json
{
  "timestamp": "2025-08-15T16:00:00Z",
  "level": "INFO",
  "message": "Transaction processed",
  "transaction_id": "tx-123",
  "user_id": "user-456",
  "amount": 1000.00
}
`

## Próximos Passos

1. **Deploy**: Executar terraform apply
2. **Configuração**: Configurar notificações de email
3. **Customização**: Ajustar dashboards conforme necessário
4. **Instrumentação**: Integrar aplicações com métricas
5. **Treinamento**: Capacitar equipe SOC
6. **Documentação**: Criar runbooks operacionais

## Contatos

- **Security Team**: security@flexcost.com.br
- **SOC Team**: soc@flexcost.com.br
- **DevOps Team**: devops@flexcost.com.br
