# Prometheus Monitoring Container App Module

Este módulo Terraform provisiona uma solução completa de monitoramento usando Azure Container Apps com Prometheus, Grafana, Node Exporter e OpenTelemetry Collector para APM.

## Arquitetura

A solução inclui:

- **Prometheus**: Servidor principal de métricas
- **Grafana**: Dashboard de visualização (sidecar ou instância separada)
- **Node Exporter**: Métricas do sistema (sidecar)
- **OpenTelemetry Collector**: APM e traces (sidecar)
- **AlertManager**: Gerenciamento de alertas (opcional)
- **Azure Application Insights**: APM nativo do Azure
- **Azure Log Analytics**: Centralização de logs
- **Azure Key Vault**: Gerenciamento de segredos
- **Azure Storage**: Persistência de dados do Prometheus

## Recursos Criados

### Core Infrastructure
- Resource Group (opcional)
- Virtual Network e Subnet (opcional)
- Container App Environment
- User Assigned Managed Identity
- Log Analytics Workspace
- Application Insights
- Key Vault
- Storage Account com File Shares

### Container Applications
- Prometheus Container App (com sidecars)
- Grafana Container App (opcional - separada)
- AlertManager Container App (opcional)

### Security & Networking
- Role-Based Access Control (RBAC)
- Azure Monitor Private Link Scope (opcional)
- Network security groups

## Uso Básico

`hcl
module "prometheus_monitoring" {
  source = "./modules/prometheus-monitoring"

  resource_group_name = "rg-monitoring-prod"
  location           = "East US"
  name_prefix        = "myapp"

  tags = {
    Environment = "Production"
    Project     = "MyApplication"
    Owner       = "DevOps Team"
  }
}
`

## Configuração Avançada

`hcl
module "prometheus_monitoring" {
  source = "./modules/prometheus-monitoring"

  # Resource Group
  create_resource_group = false
  resource_group_name  = "rg-existing-monitoring"
  location            = "East US"
  name_prefix         = "myapp"

  # Networking
  create_vnet            = true
  vnet_address_space     = "10.100.0.0/16"
  subnet_address_prefix  = "10.100.1.0/24"
  zone_redundancy_enabled = true

  # Prometheus Configuration
  prometheus_cpu         = "2.0"
  prometheus_memory      = "4Gi"
  prometheus_min_replicas = 2
  prometheus_max_replicas = 5
  prometheus_external_access = true

  # Grafana Configuration
  create_separate_grafana = true
  grafana_external_access = true
  grafana_plugins = "grafana-azure-monitor-datasource,grafana-clock-panel"

  # APM Configuration
  apm_cpu    = "0.5"
  apm_memory = "1Gi"

  # Optional Features
  enable_alertmanager = true
  enable_private_link = true

  # Storage
  prometheus_storage_size_gb = 500
  storage_replication_type  = "ZRS"

  tags = {
    Environment = "Production"
    Project     = "MyApplication"
    CostCenter  = "IT"
  }
}
`

## Configuração do Prometheus

O Prometheus pode ser configurado através da variável prometheus_config:

`hcl
module "prometheus_monitoring" {
  source = "./modules/prometheus-monitoring"
  
  prometheus_config = <<-EOT
global:
  scrape_interval: 30s
  evaluation_interval: 30s

rule_files:
  - "/etc/prometheus/alerts/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'my-application'
    static_configs:
      - targets: ['my-app.example.com:8080']

  - job_name: 'azure-container-apps'
    azure_sd_configs:
      - subscription_id: 'your-subscription-id'
        resource_group: 'your-resource-group'
        port: 80

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093
EOT
}
`

## Endpoints de Acesso

Após o deployment, você terá acesso aos seguintes endpoints:

- **Prometheus**: https://<prometheus-fqdn>
- **Grafana**: https://<grafana-fqdn> (usuário: admin)
- **AlertManager**: https://<alertmanager-fqdn> (se habilitado)

As credenciais do Grafana são armazenadas no Azure Key Vault.

## Monitoramento de Aplicações

### Instrumentação com OpenTelemetry

#### .NET Application
`csharp
using OpenTelemetry;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenTelemetry()
    .WithTracing(builder => builder
        .SetResourceBuilder(ResourceBuilder.CreateDefault()
            .AddService("MyApp"))
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri("http://otel-collector:4317");
        }));
`

#### Node.js Application
`javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-otlp-grpc');

const sdk = new NodeSDK({
  serviceName: 'my-node-app',
  traceExporter: new OTLPTraceExporter({
    url: 'http://otel-collector:4317',
  }),
});

sdk.start();
`

### Métricas Customizadas

#### Prometheus Client (Python)
`python
from prometheus_client import Counter, Histogram, start_http_server

REQUEST_COUNT = Counter('requests_total', 'Total requests')
REQUEST_LATENCY = Histogram('request_duration_seconds', 'Request latency')

# Em sua aplicação
REQUEST_COUNT.inc()
with REQUEST_LATENCY.time():
    # Seu código aqui
    pass

# Expor métricas
start_http_server(8000)
`

## Dashboards do Grafana

### Dashboards Recomendados

1. **Node Exporter Full**: ID 1860
2. **Prometheus Stats**: ID 2
3. **Azure Container Apps**: Custom dashboard
4. **Application Performance**: Custom dashboard

### Importar Dashboards

`ash
# Via API do Grafana
curl -X POST \
  https://<grafana-url>/api/dashboards/import \
  -H 'Authorization: Bearer <api-token>' \
  -H 'Content-Type: application/json' \
  -d '{"dashboard": {...}, "overwrite": true}'
`

## Alertas

### Configuração de Alertas no Prometheus

`yaml
# alerts/basic.yml
groups:
  - name: basic
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"

      - alert: ContainerAppDown
        expr: up{job="azure-container-apps"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Container App is down"
          description: "Container App {{ $labels.instance }} has been down for more than 2 minutes"
`

## Segurança

### Managed Identity
- Todas as operações usam User Assigned Managed Identity
- Nenhuma chave é armazenada em texto plano
- Acesso baseado em RBAC do Azure

### Network Security
- Container Apps em subnet dedicada
- Private Link opcional para Azure Monitor
- Firewalls configuráveis

### Secrets Management
- Passwords armazenadas no Azure Key Vault
- Rotação automática de segredos
- Acesso controlado via RBAC

## Scaling e Performance

### Auto Scaling
- Prometheus: 1-5 replicas (configurável)
- Grafana: 1-3 replicas (configurável)
- Baseado em CPU e memória

### Resource Allocation
- **Prometheus**: 1-2 CPU, 2-4Gi RAM
- **Grafana**: 0.5-1 CPU, 1-2Gi RAM
- **Node Exporter**: 0.1 CPU, 0.2Gi RAM
- **OTEL Collector**: 0.25-0.5 CPU, 0.5-1Gi RAM

## Backup e Disaster Recovery

### Data Persistence
- Prometheus data em Azure File Shares
- Backup automático das configurações
- Snapshots regulares do storage

### Recovery Procedures
1. Recrear infraestrutura via Terraform
2. Restaurar dados do storage backup
3. Reconfigurar targets e dashboards

## Monitoramento de Custos

### Cost Optimization
- Use storage LRS para desenvolvimento
- Zone redundancy apenas para produção
- Scale down em ambientes não-produtivos

### Cost Monitoring
`hcl
# Cost alerts
resource "azurerm_monitor_metric_alert" "cost_alert" {
  name                = "high-cost-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_resource_group.monitoring.id]
  
  criteria {
    metric_namespace = "Microsoft.CostManagement"
    metric_name      = "ActualCost"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100
  }
}
`

## Troubleshooting

### Common Issues

1. **Container App não inicia**
   - Verifique logs: z containerapp logs show
   - Valide configuração: z containerapp show

2. **Prometheus não coleta métricas**
   - Verifique targets: https://<prometheus-url>/targets
   - Valide network connectivity

3. **Grafana não conecta ao Prometheus**
   - Verifique datasource configuration
   - Valide network policies

### Debug Commands

`ash
# Container App logs
az containerapp logs show --name prometheus-app --resource-group rg-monitoring

# Container App status
az containerapp show --name prometheus-app --resource-group rg-monitoring

# Storage account access
az storage share list --account-name <storage-account>

# Key Vault secrets
az keyvault secret list --vault-name <keyvault-name>
`

## Variáveis Disponíveis

| Variável | Tipo | Padrão | Descrição |
|----------|------|---------|-----------|
| create_resource_group | bool | true | Criar novo resource group |
| esource_group_name | string | - | Nome do resource group |
| location | string | "East US" | Região do Azure |
| 
ame_prefix | string | "prom" | Prefixo para recursos |
| prometheus_cpu | string | "1.0" | CPU para Prometheus |
| prometheus_memory | string | "2Gi" | Memória para Prometheus |
| create_separate_grafana | bool | false | Grafana em container separado |
| nable_alertmanager | bool | false | Habilitar AlertManager |
| nable_private_link | bool | false | Habilitar Private Link |

## Outputs Principais

| Output | Descrição |
|--------|-----------|
| prometheus_url | URL do Prometheus |
| grafana_url | URL do Grafana |
| pplication_insights_connection_string | Connection string do App Insights |
| monitoring_endpoints | Map com todos os endpoints |

## Requisitos

- Terraform >= 1.0
- Azure CLI configurado
- Permissões adequadas no Azure
- Provider azurerm >= 3.117.0

## Exemplos de Uso

Veja a pasta xamples/ para configurações específicas:
- Development environment
- Production environment
- Multi-region setup
- Integration with existing infrastructure

## Contribuição

1. Fork o repositório
2. Crie uma feature branch
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## Licença

Este módulo está licenciado sob MIT License.
