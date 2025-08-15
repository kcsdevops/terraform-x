# Guia de Integração - Prometheus Monitoring Container App

Este guia fornece instruções detalhadas para implementar e integrar a solução de monitoramento Prometheus com sidecar e APM no Azure Container Apps.

## Índice

1. [Visão Geral da Arquitetura](#visão-geral-da-arquitetura)
2. [Pré-requisitos](#pré-requisitos)
3. [Implementação](#implementação)
4. [Configuração de APM](#configuração-de-apm)
5. [Integração com Aplicações](#integração-com-aplicações)
6. [Dashboards e Visualização](#dashboards-e-visualização)
7. [Alertas e Notificações](#alertas-e-notificações)
8. [Troubleshooting](#troubleshooting)
9. [Melhores Práticas](#melhores-práticas)
10. [Exemplos de Código](#exemplos-de-código)

## Visão Geral da Arquitetura

### Componentes Principais

`
┌─────────────────────────────────────────────────────────────┐
│                Azure Container App Environment              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Prometheus Container App               │ │
│  │  ┌─────────────┐ ┌──────────────┐ ┌───────────────┐  │ │
│  │  │ Prometheus  │ │   Grafana    │ │ Node Exporter │  │ │
│  │  │   :9090     │ │    :3000     │ │     :9100     │  │ │
│  │  │             │ │   (sidecar)  │ │   (sidecar)   │  │ │
│  │  └─────────────┘ └──────────────┘ └───────────────┘  │ │
│  │  ┌─────────────────────────────────────────────────┐  │ │
│  │  │         OpenTelemetry Collector              │  │ │
│  │  │              :4317 :4318                     │  │ │
│  │  │            (APM sidecar)                     │  │ │
│  │  └─────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │         Grafana Container App (Opcional)            │ │
│  │              Instância Dedicada                    │ │
│  └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │       AlertManager Container App (Opcional)        │ │
│  │            Gerenciamento de Alertas                │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐ ┌──────────────────┐ ┌─────────────────┐
│  Azure Key      │ │ Azure Storage    │ │ Application     │
│    Vault        │ │   Account        │ │   Insights      │
│   (Secrets)     │ │ (Persistence)    │ │     (APM)       │
└─────────────────┘ └──────────────────┘ └─────────────────┘

┌─────────────────────────────────────────────────────────────┐
│            Log Analytics Workspace                         │
│          Centralização de Logs e Métricas                  │
└─────────────────────────────────────────────────────────────┘
`

### Fluxo de Dados

1. **Coleta de Métricas**: Prometheus coleta métricas de:
   - Node Exporter (métricas do sistema)
   - Aplicações instrumentadas (métricas customizadas)
   - Azure Container Apps (métricas da plataforma)
   - OpenTelemetry Collector (traces e métricas APM)

2. **Visualização**: Grafana consome dados do Prometheus
3. **APM**: OpenTelemetry Collector envia traces para Application Insights
4. **Alertas**: AlertManager processa alertas do Prometheus
5. **Logs**: Todos os logs são centralizados no Log Analytics

## Pré-requisitos

### Software Necessário
- Terraform >= 1.0
- Azure CLI >= 2.50.0
- kubectl (opcional, para debug)
- Git

### Permissões Azure
- Contributor no Resource Group
- Key Vault Administrator
- Storage Blob Data Contributor
- Monitoring Contributor

### Verificação de Instalação
`powershell
# Verificar Terraform
terraform version

# Verificar Azure CLI
az version

# Login no Azure
az login
az account show

# Verificar subscriptions disponíveis
az account list --output table
`

## Implementação

### Passo 1: Preparação do Ambiente

`powershell
# Clone ou navegue para o diretório do projeto
cd "C:\Users\Kleidir Campos\terraform"

# Verificar estrutura
Get-ChildItem -Recurse modules\prometheus-monitoring
`

### Passo 2: Configuração para Desenvolvimento

`powershell
# Navegar para o ambiente de desenvolvimento
cd dev

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar deployment
terraform plan -out=prometheus-dev.tfplan

# Aplicar configuração
terraform apply prometheus-dev.tfplan
`

### Passo 3: Configuração para Homologação

`powershell
# Navegar para o ambiente de homologação
cd ..\homologacao

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar deployment
terraform plan -out=prometheus-homolog.tfplan

# Aplicar configuração
terraform apply prometheus-homolog.tfplan
`

### Passo 4: Verificação do Deployment

`powershell
# Obter URLs dos serviços
terraform output

# Verificar status dos Container Apps
az containerapp list --resource-group rg-monitoring-dev --output table

# Verificar logs
az containerapp logs show --name <prometheus-app-name> --resource-group <resource-group>
`

## Configuração de APM

### OpenTelemetry Collector

O OpenTelemetry Collector já está configurado como sidecar e aceita:
- **OTLP gRPC**: porta 4317
- **OTLP HTTP**: porta 4318
- **Jaeger gRPC**: porta 14250
- **Zipkin**: porta 9411

### Configuração de Aplicações

#### .NET Core Application

`csharp
// Program.cs
using OpenTelemetry;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;

var builder = WebApplication.CreateBuilder(args);

// Configurar OpenTelemetry
builder.Services.AddOpenTelemetry()
    .WithTracing(builder => builder
        .SetResourceBuilder(ResourceBuilder.CreateDefault()
            .AddService("MyWebApp", "1.0.0")
            .AddAttributes(new Dictionary<string, object>
            {
                ["environment"] = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development",
                ["service.namespace"] = "MyCompany.WebApps"
            }))
        .AddAspNetCoreInstrumentation(options =>
        {
            options.RecordException = true;
            options.Filter = httpContext => !httpContext.Request.Path.StartsWithSegments("/health");
        })
        .AddHttpClientInstrumentation()
        .AddEntityFrameworkCoreInstrumentation()
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT") ?? "http://localhost:4317");
        }))
    .WithMetrics(builder => builder
        .SetResourceBuilder(ResourceBuilder.CreateDefault()
            .AddService("MyWebApp", "1.0.0"))
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddPrometheusExporter()
        .AddOtlpExporter(options =>
        {
            options.Endpoint = new Uri(Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT") ?? "http://localhost:4317");
        }));

// Adicionar Prometheus metrics endpoint
builder.Services.AddSingleton<PrometheusMetrics>();

var app = builder.Build();

// Configurar middleware
app.UseOpenTelemetryPrometheusScrapingEndpoint();

// Health checks
app.MapHealthChecks("/health");

// Prometheus metrics endpoint
app.MapGet("/metrics", async (PrometheusMetrics metrics) =>
{
    return Results.Text(await metrics.GetMetricsAsync(), "text/plain");
});

app.Run();
`

`csharp
// PrometheusMetrics.cs
public class PrometheusMetrics
{
    private readonly Counter _requestCounter;
    private readonly Histogram _requestDuration;
    private readonly Gauge _activeConnections;

    public PrometheusMetrics()
    {
        var factory = Metrics.NewCollectorRegistry();
        
        _requestCounter = Metrics
            .CreateCounter("http_requests_total", "Total HTTP requests")
            .WithLabels("method", "endpoint", "status");
            
        _requestDuration = Metrics
            .CreateHistogram("http_request_duration_seconds", "HTTP request duration")
            .WithLabels("method", "endpoint");
            
        _activeConnections = Metrics
            .CreateGauge("active_connections", "Number of active connections");
    }

    public void RecordRequest(string method, string endpoint, int statusCode, double duration)
    {
        _requestCounter.WithLabels(method, endpoint, statusCode.ToString()).Inc();
        _requestDuration.WithLabels(method, endpoint).Observe(duration);
    }

    public async Task<string> GetMetricsAsync()
    {
        return await Task.FromResult(ScrapeHandler.ProcessAsync(CollectorRegistry.Instance));
    }
}
`

#### Node.js Application

`javascript
// server.js
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-otlp-grpc');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-otlp-grpc');
const { PrometheusExporter } = require('@opentelemetry/exporter-prometheus');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');
const prometheus = require('prom-client');

// Configurar OpenTelemetry
const sdk = new NodeSDK({
  serviceName: 'my-node-app',
  serviceVersion: '1.0.0',
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4317',
  }),
  metricExporter: new OTLPMetricExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4317',
  }),
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
});

sdk.start();

// Configurar Prometheus metrics
const register = new prometheus.Registry();
prometheus.collectDefaultMetrics({ register });

const httpRequestsTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'],
  registers: [register],
});

// Express app
const express = require('express');
const app = express();

// Middleware para métricas
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestsTotal.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status: res.statusCode,
    });
    httpRequestDuration.observe(
      { method: req.method, route: req.route?.path || req.path },
      duration
    );
  });
  
  next();
});

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
`

#### Python Application (FastAPI)

`python
# main.py
from fastapi import FastAPI, Request
from opentelemetry import trace, metrics
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import os

# Configurar OpenTelemetry
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configurar exporters
otlp_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317")

span_processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=otlp_endpoint))
trace.get_tracer_provider().add_span_processor(span_processor)

metrics.set_meter_provider(MeterProvider(
    metric_readers=[PeriodicExportingMetricReader(
        OTLPMetricExporter(endpoint=otlp_endpoint),
        export_interval_millis=30000
    )]
))

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])

app = FastAPI()

# Instrumentar FastAPI
FastAPIInstrumentor.instrument_app(app)
HTTPXClientInstrumentor().instrument()

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=str(request.url.path),
        status=response.status_code
    ).inc()
    
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=str(request.url.path)
    ).observe(duration)
    
    return response

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/metrics")
async def prometheus_metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/")
async def root():
    with tracer.start_as_current_span("root_handler"):
        return {"message": "Hello World"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
`

## Dashboards e Visualização

### Acessar Grafana

`powershell
# Obter URL do Grafana
terraform output grafana_url

# Obter senha do admin
az keyvault secret show --vault-name <key-vault-name> --name grafana-admin-password --query value -o tsv
`

### Dashboards Recomendados

1. **Node Exporter Full (ID: 1860)**
   - Métricas detalhadas do sistema
   - CPU, memória, disco, rede

2. **Prometheus Stats (ID: 2)**
   - Estatísticas do próprio Prometheus
   - Performance e health checks

3. **Azure Container Apps (Custom)**
   - Métricas específicas do Azure
   - Scaling e performance

### Importar Dashboard Customizado

`json
{
  "dashboard": {
    "title": "Azure Container Apps Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{instance}} - {{method}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~\"5..\"}[5m]) / rate(http_requests_total[5m]) * 100"
          }
        ]
      }
    ]
  }
}
`

## Alertas e Notificações

### Configurar Notificações por Email

`yaml
# No AlertManager
global:
  smtp_smarthost: 'smtp.office365.com:587'
  smtp_from: 'alerts@company.com'
  smtp_auth_username: 'alerts@company.com'
  smtp_auth_password: '<password>'

receivers:
  - name: 'devops-team'
    email_configs:
      - to: 'devops@company.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        html: |
          <h2>Alert Details</h2>
          {{ range .Alerts }}
          <p><strong>Alert:</strong> {{ .Annotations.summary }}</p>
          <p><strong>Description:</strong> {{ .Annotations.description }}</p>
          <p><strong>Status:</strong> {{ .Status }}</p>
          {{ end }}
`

### Integração com Microsoft Teams

`yaml
receivers:
  - name: 'teams-alerts'
    webhook_configs:
      - url: 'https://outlook.office.com/webhook/YOUR-WEBHOOK-URL'
        send_resolved: true
        title: 'Prometheus Alert'
        text: |
          {{ range .Alerts }}
          **Alert:** {{ .Annotations.summary }}
          **Status:** {{ .Status }}
          **Instance:** {{ .Labels.instance }}
          {{ end }}
`

## Troubleshooting

### Problemas Comuns

#### 1. Container App não inicia

`powershell
# Verificar logs detalhados
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow

# Verificar configuração
az containerapp show --name <app-name> --resource-group <rg-name> --query properties

# Verificar eventos
az containerapp revision list --name <app-name> --resource-group <rg-name>
`

#### 2. Prometheus não coleta métricas

`powershell
# Verificar targets no Prometheus
curl "https://<prometheus-url>/targets"

# Verificar configuração
curl "https://<prometheus-url>/config"

# Teste de conectividade
az containerapp exec --name <app-name> --resource-group <rg-name> --container prometheus --command "wget -qO- http://localhost:9100/metrics"
`

#### 3. Grafana não conecta ao Prometheus

`powershell
# Verificar datasource
curl -u admin:<password> "https://<grafana-url>/api/datasources"

# Testar conexão manualmente
az containerapp exec --name <app-name> --resource-group <rg-name> --container grafana --command "curl http://localhost:9090/api/v1/query?query=up"
`

### Debug Commands

`powershell
# Container App status
az containerapp show --name <app-name> --resource-group <rg-name> --query properties.provisioningState

# Revision status
az containerapp revision list --name <app-name> --resource-group <rg-name> --query '[].{Name:name,Active:properties.active,Healthy:properties.healthState}'

# Network connectivity test
az containerapp exec --name <app-name> --resource-group <rg-name> --command "nslookup <target-host>"

# Storage mount test
az containerapp exec --name <app-name> --resource-group <rg-name> --command "ls -la /prometheus/data"

# Environment variables
az containerapp exec --name <app-name> --resource-group <rg-name> --command "printenv | grep -i prom"
`

## Melhores Práticas

### Performance
1. **Resource Allocation**: Ajuste CPU/memória baseado no uso
2. **Storage**: Use SSD para dados do Prometheus
3. **Retention**: Configure retenção apropriada (15 dias dev, 90 dias prod)

### Segurança
1. **Network Isolation**: Use subnets dedicadas
2. **Authentication**: Configure autenticação para Grafana
3. **RBAC**: Implemente least privilege access

### Monitoring
1. **Self-Monitoring**: Monitor o próprio Prometheus
2. **Alerting**: Configure alertas críticos
3. **Backup**: Backup regular das configurações

### Cost Optimization
1. **Scaling**: Configure auto-scaling apropriado
2. **Storage Tiers**: Use appropriate storage tiers
3. **Development**: Scale down em ambientes não-prod

## Exemplos de Código

### Custom Metrics em .NET

`csharp
public class BusinessMetrics
{
    private static readonly Counter OrdersProcessed = Metrics
        .CreateCounter("orders_processed_total", "Total orders processed");
    
    private static readonly Histogram OrderProcessingTime = Metrics
        .CreateHistogram("order_processing_duration_seconds", "Order processing time");
    
    private static readonly Gauge ActiveUsers = Metrics
        .CreateGauge("active_users", "Number of active users");

    public void RecordOrderProcessed(double processingTime)
    {
        OrdersProcessed.Inc();
        OrderProcessingTime.Observe(processingTime);
    }

    public void UpdateActiveUsers(int count)
    {
        ActiveUsers.Set(count);
    }
}
`

### Health Checks Personalizados

`csharp
public class DatabaseHealthCheck : IHealthCheck
{
    private readonly IDbConnection _connection;

    public DatabaseHealthCheck(IDbConnection connection)
    {
        _connection = connection;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _connection.ExecuteScalarAsync("SELECT 1");
            return HealthCheckResult.Healthy("Database is responsive");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy("Database is not responsive", ex);
        }
    }
}
`

### Configuração de Deployment

`powershell
# Script de deployment automatizado
param(
    [Parameter(Mandatory=True)]
    [string],
    
    [Parameter(Mandatory=False)]
    [switch]
)

Continue = "Stop"

Write-Host "Deploying Prometheus monitoring to  environment..." -ForegroundColor Green

# Navegar para o diretório correto
Set-Location 

# Inicializar se necessário
if (-not (Test-Path ".terraform")) {
    Write-Host "Initializing Terraform..." -ForegroundColor Yellow
    terraform init
}

# Validar configuração
Write-Host "Validating configuration..." -ForegroundColor Yellow
terraform validate

if (-not ) {
    # Planejar deployment
    Write-Host "Planning deployment..." -ForegroundColor Yellow
    terraform plan -out="prometheus-.tfplan"
    
    # Confirmar deployment
     = Read-Host "Do you want to apply this plan? (yes/no)"
    if ( -ne "yes") {
        Write-Host "Deployment cancelled." -ForegroundColor Red
        exit 1
    }
}

# Aplicar configuração
Write-Host "Applying configuration..." -ForegroundColor Yellow
terraform apply "prometheus-.tfplan"

# Mostrar outputs
Write-Host "Deployment completed! Here are the outputs:" -ForegroundColor Green
terraform output

Write-Host "Prometheus monitoring is now available in  environment." -ForegroundColor Green
`

## Próximos Passos

1. **Deploy da Infraestrutura**: Execute o Terraform nos ambientes desejados
2. **Configurar Aplicações**: Instrumente suas aplicações com OpenTelemetry
3. **Criar Dashboards**: Importe ou crie dashboards customizados
4. **Configurar Alertas**: Defina alertas críticos para seu negócio
5. **Treinar Equipe**: Capacite a equipe para usar as ferramentas
6. **Monitorar Custos**: Implemente alertas de custo
7. **Backup**: Configure backup das configurações críticas

## Suporte

Para dúvidas ou problemas:
1. Verifique a documentação oficial do Prometheus e Grafana
2. Consulte os logs dos Container Apps
3. Revisite este guia de troubleshooting
4. Contate a equipe de DevOps

---

**Versão**: 1.0  
**Data**: August 2025  
**Autor**: DevOps Team
