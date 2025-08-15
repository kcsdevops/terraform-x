# ARQUITETURA COMPLETA - INFRAESTRUTURA AZURE 2024

## VISAO GERAL DO SISTEMA

### Ambientes Implementados
```
DESENVOLVIMENTO → HOMOLOGACAO → PRODUCAO
     (Basic)         (Standard)     (Premium)
```

## COMPONENTES PRINCIPAIS

### 1. IDENTITY MANAGEMENT (Keycloak)
```
┌─────────────────────────────────────────────────────────────┐
│                    KEYCLOAK IDENTITY                        │
├─────────────────────────────────────────────────────────────┤
│ Container App:     keycloak/keycloak:latest                 │
│ Database:          PostgreSQL Flexible Server              │
│ Storage:           Azure Key Vault (secrets centralizados) │
│ Network:           Private endpoint + VNet integration      │
│ Health Checks:     /auth/health/ready                       │
│ SSL:               TLS 1.2+ com certificados automaticos   │
├─────────────────────────────────────────────────────────────┤
│ Funcionalidades:                                            │
│ - Single Sign-On (SSO)                                      │
│ - SAML, OAuth 2.0, OpenID Connect                          │
│ - User Federation                                           │
│ - Role-Based Access Control                                 │
│ - Multi-tenancy                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. MONITORING STACK (Prometheus + Grafana)
```
┌─────────────────────────────────────────────────────────────┐
│                   PROMETHEUS MONITORING                     │
├─────────────────────────────────────────────────────────────┤
│ Main Container:    prometheus/prometheus:latest             │
│ Sidecar 1:         grafana/grafana:latest                  │
│ Sidecar 2:         quay.io/prometheus/node-exporter        │
│ Sidecar 3:         otel/opentelemetry-collector            │
├─────────────────────────────────────────────────────────────┤
│ Recursos:                                                   │
│ - CPU: 1 core / Memory: 2Gi                                │
│ - Storage: 50Gi para metricas historicas                   │
│ - Network: Ingress HTTPS habilitado                        │
├─────────────────────────────────────────────────────────────┤
│ Integracao:                                                 │
│ - Azure Application Insights                               │
│ - Log Analytics Workspace                                  │
│ - Azure Monitor Metrics                                    │
│ - Custom dashboards e alertas                              │
└─────────────────────────────────────────────────────────────┘
```

### 3. DATABASE LAYER
```
┌─────────────────────────────────────────────────────────────┐
│                      DATABASES                              │
├─────────────────────────────────────────────────────────────┤
│ SQL SERVER (Aplicacoes)                                     │
│ ├─ DEV:      Basic tier     (dev-sqlsrv-min)               │
│ ├─ HOMOLOG:  Standard S0    (hml-sqlsrv-min)               │
│ └─ PROD:     Premium P1     (prd-sqlsrv-enterprise)        │
├─────────────────────────────────────────────────────────────┤
│ POSTGRESQL (Keycloak)                                       │
│ ├─ Flexible Server                                          │
│ ├─ Private networking                                       │
│ ├─ Automated backups                                        │
│ └─ High availability (PROD only)                            │
├─────────────────────────────────────────────────────────────┤
│ Seguranca:                                                  │
│ - TDE (Transparent Data Encryption)                        │
│ - Connection strings via Key Vault                         │
│ - VNet integration                                          │
│ - Audit logs habilitados                                   │
└─────────────────────────────────────────────────────────────┘
```

## NETWORK ARCHITECTURE

### Isolamento por Ambiente
```
┌─────────────────────────────────────────────────────────────┐
│                    NETWORK TOPOLOGY                         │
├─────────────────────────────────────────────────────────────┤
│ DEV Environment (10.100.0.0/16)                            │
│ ├─ Container Apps Subnet:    10.100.1.0/24                 │
│ ├─ Database Subnet:          10.100.2.0/24                 │
│ └─ Private Endpoints:        10.100.3.0/24                 │
├─────────────────────────────────────────────────────────────┤
│ HOMOLOG Environment (10.200.0.0/16)                        │
│ ├─ Container Apps Subnet:    10.200.1.0/24                 │
│ ├─ Database Subnet:          10.200.2.0/24                 │
│ └─ Private Endpoints:        10.200.3.0/24                 │
├─────────────────────────────────────────────────────────────┤
│ PRODUCAO Environment (10.300.0.0/16)                       │
│ ├─ Container Apps Subnet:    10.300.1.0/24                 │
│ ├─ Database Subnet:          10.300.2.0/24                 │
│ ├─ Private Endpoints:        10.300.3.0/24                 │
│ └─ Management Subnet:        10.300.4.0/24                 │
├─────────────────────────────────────────────────────────────┤
│ Security Groups:                                            │
│ - Deny all por padrao                                       │
│ - Allow HTTP/HTTPS entrada                                  │
│ - Allow database ports internos                             │
│ - Allow monitoring ports                                    │
└─────────────────────────────────────────────────────────────┘
```

## SECURITY ARCHITECTURE

### Azure Key Vault Integration
```
┌─────────────────────────────────────────────────────────────┐
│                    AZURE KEY VAULT                          │
├─────────────────────────────────────────────────────────────┤
│ Secrets Centralizados:                                     │
│ ├─ keycloak-db-connection-string                           │
│ ├─ keycloak-admin-password                                 │
│ ├─ sql-server-admin-password                               │
│ ├─ prometheus-grafana-admin-password                       │
│ └─ application-insights-connection-string                  │
├─────────────────────────────────────────────────────────────┤
│ Access Policies:                                            │
│ ├─ Managed Identity para Container Apps                    │
│ ├─ RBAC granular por ambiente                              │
│ └─ Audit logs para todos acessos                           │
├─────────────────────────────────────────────────────────────┤
│ Compliance:                                                 │
│ ├─ FIPS 140-2 Level 2 validated HSMs                       │
│ ├─ Certificate management                                   │
│ └─ Key rotation automatizada                                │
└─────────────────────────────────────────────────────────────┘
```

## DEPLOYMENT ARCHITECTURE

### Terraform Modules Structure
```
terraform/
├── environments/
│   ├── dev/main.tf           (Basic tier, custo otimizado)
│   ├── homologacao/main.tf   (Standard tier, performance)
│   └── producao/main.tf      (Premium tier, enterprise)
├── modules/
│   ├── keycloak-container-app/    (Identity management)
│   ├── prometheus-monitoring/     (Observability stack)
│   ├── sql/                       (Database layer)
│   ├── vnet/                      (Network foundation)
│   ├── keyvault/                  (Secrets management)
│   └── storage/                   (Persistent storage)
```

## OBSERVABILITY STACK

### Metrics Collection
```
┌─────────────────────────────────────────────────────────────┐
│                   METRICS PIPELINE                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Node Exporter    → System metrics (CPU, memory, disk)    │
│ 2. Prometheus       → Application metrics                   │
│ 3. OTEL Collector   → Distributed tracing                   │
│ 4. Grafana          → Visualization dashboards              │
│ 5. Azure Monitor    → Cloud-native integration              │
├─────────────────────────────────────────────────────────────┤
│ Dashboard Categories:                                       │
│ ├─ Infrastructure: CPU, memory, network, storage           │
│ ├─ Applications: Response time, errors, throughput         │
│ ├─ Business: User sessions, transactions, revenue          │
│ └─ Security: Authentication, authorization, threats        │
└─────────────────────────────────────────────────────────────┘
```

## COST OPTIMIZATION

### Resource Sizing by Environment
```
┌─────────────────────────────────────────────────────────────┐
│                   COST OPTIMIZATION                         │
├─────────────────────────────────────────────────────────────┤
│ DEV (Custo Minimo):                                         │
│ ├─ Container Apps: Consumption plan                        │
│ ├─ SQL Database: Basic (5 DTU)                             │
│ ├─ Storage: Standard LRS                                   │
│ └─ Estimated: R$ 200/mes                                   │
├─────────────────────────────────────────────────────────────┤
│ HOMOLOG (Performance Adequada):                            │
│ ├─ Container Apps: Dedicated plan (1 core)                 │
│ ├─ SQL Database: Standard S0 (10 DTU)                      │
│ ├─ Storage: Standard LRS                                   │
│ └─ Estimated: R$ 800/mes                                   │
├─────────────────────────────────────────────────────────────┤
│ PRODUCAO (Enterprise Grade):                               │
│ ├─ Container Apps: Premium plan (2+ cores)                 │
│ ├─ SQL Database: Premium P1 (125 DTU)                      │
│ ├─ Storage: Premium SSD                                    │
│ ├─ Backup: GRS with long-term retention                    │
│ └─ Estimated: R$ 3000/mes                                  │
└─────────────────────────────────────────────────────────────┘
```

**Arquitetura enterprise-ready com identity management centralizado e observabilidade completa**
