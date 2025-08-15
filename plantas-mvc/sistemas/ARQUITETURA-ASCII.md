# ARQUITETURA DE SISTEMAS - IDENTITY & MONITORING 2024

## VISAO GERAL DA ARQUITETURA ENTERPRISE

```
                            AZURE CLOUD - BRAZIL SOUTH
    ┌─────────────────────────────────────────────────────────────────────────────────────┐
    │  TERRAFORM STATE: Remote Backend (Storage Account)                                 │
    │  SERVICE PRINCIPAL: Managed Identity para deploy automatizado                      │
    │  ENVIRONMENTS: Dev → Homolog → Producao (Isolation Completa)                       │
    └─────────────────────────────────────────────────────────────────────────────────────┘
                                           │
                ┌──────────────────────────┼──────────────────────────┐
                │                          │                          │
    ┌───────────▼──────────────┐          │          ┌───────────▼──────────────┐
    │   DEV ENVIRONMENT        │          │          │   HOMOLOG ENVIRONMENT    │
    │   (Basic Tier)           │    NETWORK ISOLATED   │   (Standard Tier)       │
    │   10.100.0.0/16          │          │          │   10.200.0.0/16          │
    └───────────────────────────┘          │          └───────────────────────────┘
                                           │
                                           ▼
                                ┌───────────────────────┐
                                │   PRODUCAO ENVIRONMENT │
                                │   (Premium Tier)       │
                                │   10.300.0.0/16        │
                                └───────────────────────┘
```

## AMBIENTE DESENVOLVIMENTO - ARQUITETURA DETALHADA

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEV ENVIRONMENT DETAILS                         │
│                     (10.100.0.0/16)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ CONTAINER APPS ENVIRONMENT ──────────────────────────────────┐  │
│  │                         (10.100.1.0/24)                       │  │
│  │                                                                │  │
│  │   ┌───────────────────────────────────────────────────────┐   │  │
│  │   │                KEYCLOAK IDENTITY                      │   │  │
│  │   │                                                       │   │  │
│  │   │  Container: keycloak/keycloak:latest                  │   │  │
│  │   │  CPU: 0.5 core  Memory: 1Gi                         │   │  │
│  │   │  Port: 8080                                          │   │  │
│  │   │  Health: /auth/health/ready                          │   │  │
│  │   │  Replicas: 1 (min: 1, max: 2)                       │   │  │
│  │   │                                                       │   │  │
│  │   │  Features:                                            │   │  │
│  │   │  • Single Sign-On (SSO)                              │   │  │
│  │   │  • OAuth 2.0 / OpenID Connect                        │   │  │
│  │   │  • SAML 2.0 Support                                  │   │  │
│  │   │  • User Federation                                   │   │  │
│  │   │  • Multi-tenant Ready                                │   │  │
│  │   └───────────────┬───────────────────────────────────────┘   │  │
│  │                   │                                           │  │
│  │   ┌───────────────▼───────────────────────────────────────┐   │  │
│  │   │              PROMETHEUS MONITORING                    │   │  │
│  │   │                                                       │   │  │
│  │   │  Main Container: prometheus/prometheus:latest         │   │  │
│  │   │  CPU: 0.5 core  Memory: 1Gi                         │   │  │
│  │   │  Port: 9090                                          │   │  │
│  │   │                                                       │   │  │
│  │   │  Sidecar Containers:                                  │   │  │
│  │   │  ├─ Grafana (grafana/grafana:latest)                │   │  │
│  │   │  ├─ Node Exporter (prom/node-exporter)              │   │  │
│  │   │  └─ OTEL Collector (otel/opentelemetry-collector)   │   │  │
│  │   │                                                       │   │  │
│  │   │  Storage: 10Gi (metrics retention)                   │   │  │
│  │   │  Replicas: 1 (dev optimization)                      │   │  │
│  │   └───────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                │                                       │
│  ┌─ DATABASE LAYER ────────────▼───────────────────────────────────┐  │
│  │                        (10.100.2.0/24)                         │  │
│  │                                                                 │  │
│  │   ┌─────────────────────┐        ┌─────────────────────────┐   │  │
│  │   │   POSTGRESQL        │        │     SQL SERVER         │   │  │
│  │   │   (Keycloak Store)  │        │  (Business Database)   │   │  │
│  │   │                     │        │                         │   │  │
│  │   │ • Flexible Server   │        │ • Basic Tier (5 DTU)   │   │  │
│  │   │ • Version: 15       │        │ • Storage: 2GB         │   │  │
│  │   │ • Compute: B1ms     │        │ • Backup: 7 days       │   │  │
│  │   │ • Storage: 32GB     │        │ • TDE Enabled          │   │  │
│  │   │ • Private Network   │        │ • Private Endpoint     │   │  │
│  │   │ • SSL Required      │        │ • Managed Identity     │   │  │
│  │   └─────────────────────┘        └─────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                │                                       │
│  ┌─ SECURITY & SECRETS ────────▼───────────────────────────────────┐  │
│  │                                                                 │  │
│  │   ┌─────────────────────────────────────────────────────────┐   │  │
│  │   │                AZURE KEY VAULT                          │   │  │
│  │   │                                                         │   │  │
│  │   │  Secrets Stored:                                        │   │  │
│  │   │  ├─ keycloak-db-connection-string                       │   │  │
│  │   │  ├─ keycloak-admin-password                             │   │  │
│  │   │  ├─ sql-server-connection-string                        │   │  │
│  │   │  ├─ prometheus-admin-password                           │   │  │
│  │   │  └─ application-insights-key                            │   │  │
│  │   │                                                         │   │  │
│  │   │  Access Method:                                         │   │  │
│  │   │  • Managed Identity (Container Apps)                   │   │  │
│  │   │  • RBAC Policies                                       │   │  │
│  │   │  • Audit Logs Enabled                                  │   │  │
│  │   │  • Soft Delete Protection                              │   │  │
│  │   └─────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## AMBIENTE HOMOLOGACAO - ARQUITETURA DETALHADA

```
┌─────────────────────────────────────────────────────────────────────┐
│                  HOMOLOG ENVIRONMENT DETAILS                       │
│                     (10.200.0.0/16)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ CONTAINER APPS ENVIRONMENT ──────────────────────────────────┐  │
│  │                         (10.200.1.0/24)                       │  │
│  │                                                                │  │
│  │   ┌───────────────────────────────────────────────────────┐   │  │
│  │   │           KEYCLOAK IDENTITY (PRODUCTION MODE)         │   │  │
│  │   │                                                       │   │  │
│  │   │  Container: keycloak/keycloak:latest                  │   │  │
│  │   │  CPU: 1 core  Memory: 2Gi                           │   │  │
│  │   │  Port: 8080 (HTTPS enabled)                         │   │  │
│  │   │  Health: /auth/health/ready                          │   │  │
│  │   │  Replicas: 2 (min: 1, max: 5)                       │   │  │
│  │   │                                                       │   │  │
│  │   │  Advanced Features:                                   │   │  │
│  │   │  • High Availability Mode                            │   │  │
│  │   │  • Load Testing Ready                                │   │  │
│  │   │  • Performance Monitoring                            │   │  │
│  │   │  • User Federation (Azure AD)                        │   │  │
│  │   │  • Social Logins (Google, Facebook)                 │   │  │
│  │   └───────────────┬───────────────────────────────────────┘   │  │
│  │                   │                                           │  │
│  │   ┌───────────────▼───────────────────────────────────────┐   │  │
│  │   │         PROMETHEUS MONITORING (ENTERPRISE)           │   │  │
│  │   │                                                       │   │  │
│  │   │  Main Container: prometheus/prometheus:latest         │   │  │
│  │   │  CPU: 1 core  Memory: 2Gi                           │   │  │
│  │   │  Port: 9090                                          │   │  │
│  │   │                                                       │   │  │
│  │   │  Advanced Sidecars:                                   │   │  │
│  │   │  ├─ Grafana (enterprise dashboards)                 │   │  │
│  │   │  ├─ AlertManager (advanced alerting)                │   │  │
│  │   │  ├─ Node Exporter (system metrics)                  │   │  │
│  │   │  ├─ OTEL Collector (APM + tracing)                  │   │  │
│  │   │  └─ Pushgateway (batch job metrics)                 │   │  │
│  │   │                                                       │   │  │
│  │   │  Storage: 50Gi (extended retention)                  │   │  │
│  │   │  Replicas: 2 (HA configuration)                      │   │  │
│  │   │  Integration: Azure Application Insights             │   │  │
│  │   └───────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                │                                       │
│  ┌─ DATABASE LAYER (ENHANCED) ─▼───────────────────────────────────┐  │
│  │                        (10.200.2.0/24)                         │  │
│  │                                                                 │  │
│  │   ┌─────────────────────┐        ┌─────────────────────────┐   │  │
│  │   │   POSTGRESQL        │        │     SQL SERVER         │   │  │
│  │   │   (Keycloak HA)     │        │  (Business Enhanced)   │   │  │
│  │   │                     │        │                         │   │  │
│  │   │ • HA Zone Redundant │        │ • Standard S0 (10 DTU) │   │  │
│  │   │ • Read Replicas     │        │ • Storage: 250GB       │   │  │
│  │   │ • Auto-Failover     │        │ • Backup: 30 days      │   │  │
│  │   │ • Point-in-Time     │        │ • Geo-Replication      │   │  │
│  │   │ • Performance Tuned │        │ • Advanced Security     │   │  │
│  │   │ • Monitoring Active │        │ • Query Performance    │   │  │
│  │   └─────────────────────┘        └─────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                │                                       │
│  ┌─ MONITORING & OBSERVABILITY ▼───────────────────────────────────┐  │
│  │                                                                 │  │
│  │   ┌─────────────────────────────────────────────────────────┐   │  │
│  │   │            AZURE APPLICATION INSIGHTS                   │   │  │
│  │   │                                                         │   │  │
│  │   │  • Distributed Tracing                                 │   │  │
│  │   │  • Performance Monitoring                              │   │  │
│  │   │  • Dependency Tracking                                 │   │  │
│  │   │  • Custom Metrics & Events                             │   │  │
│  │   │  • Real User Monitoring                                │   │  │
│  │   │  • Availability Tests                                  │   │  │
│  │   └─────────────────────────────────────────────────────────┘   │  │
│  │                                                                 │  │
│  │   ┌─────────────────────────────────────────────────────────┐   │  │
│  │   │               LOG ANALYTICS WORKSPACE                   │   │  │
│  │   │                                                         │   │  │
│  │   │  • Centralized Logging                                 │   │  │
│  │   │  • KQL Queries                                         │   │  │
│  │   │  • Custom Dashboards                                   │   │  │
│  │   │  • Automated Alerts                                    │   │  │
│  │   │  • Security Analytics                                  │   │  │
│  │   │  • Performance Baselines                               │   │  │
│  │   └─────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## FLUXO DE AUTENTICACAO E AUTORIZACAO

```
┌─────────────────────────────────────────────────────────────────────┐
│                  AUTHENTICATION & AUTHORIZATION FLOW               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. USER LOGIN PROCESS                                              │
│                                                                     │
│     ┌─────────────┐    1. Access App    ┌─────────────────────┐     │
│     │   CLIENT    │ ─────────────────▶  │   BUSINESS APP      │     │
│     │ (Frontend)  │                     │  (Container App)    │     │
│     └─────────────┘                     └──────────┬──────────┘     │
│            │                                       │                │
│            │ 2. Redirect to SSO                    │                │
│            ▼                                       │                │
│     ┌─────────────┐                                │                │
│     │  KEYCLOAK   │ ◀──────────────────────────────┘                │
│     │ (Identity)  │                                                 │
│     └─────┬───────┘                                                 │
│           │                                                         │
│           │ 3. Present Login                                        │
│           ▼                                                         │
│     ┌─────────────┐                                                 │
│     │   CLIENT    │                                                 │
│     │ (Login UI)  │                                                 │
│     └─────┬───────┘                                                 │
│           │                                                         │
│           │ 4. Submit Credentials                                   │
│           ▼                                                         │
│     ┌─────────────┐    5. Validate      ┌─────────────────────┐     │
│     │  KEYCLOAK   │ ─────────────────▶  │   POSTGRESQL        │     │
│     │ (Identity)  │                     │  (User Store)       │     │
│     └─────┬───────┘                     └─────────────────────┘     │
│           │                                                         │
│           │ 6. Issue JWT Token                                      │
│           ▼                                                         │
│     ┌─────────────┐                                                 │
│     │   CLIENT    │                                                 │
│     │ (With Token)│                                                 │
│     └─────┬───────┘                                                 │
│           │                                                         │
│           │ 7. Access with Token                                    │
│           ▼                                                         │
│     ┌─────────────┐    8. Validate JWT   ┌─────────────────────┐     │
│     │BUSINESS APP │ ─────────────────▶   │   KEYCLOAK API      │     │
│     │             │                      │  (Token Validation) │     │
│     └─────┬───────┘                      └─────────────────────┘     │
│           │                                                         │
│           │ 9. Access Database                                      │
│           ▼                                                         │
│     ┌─────────────┐                                                 │
│     │ SQL SERVER  │                                                 │
│     │(Business DB)│                                                 │
│     └─────────────┘                                                 │
│                                                                     │
│  2. MONITORING FLOW                                                 │
│                                                                     │
│     ┌─────────────┐   Metrics/Logs    ┌─────────────────────┐       │
│     │BUSINESS APP │ ─────────────────▶ │   PROMETHEUS        │       │
│     │             │                   │  (Collection)       │       │
│     └─────────────┘                   └──────────┬──────────┘       │
│                                                  │                  │
│     ┌─────────────┐                              │                  │
│     │  KEYCLOAK   │ ─────────────────────────────┘                  │
│     │ (Identity)  │   Authentication Metrics                       │
│     └─────────────┘                                                 │
│                                                  │                  │
│                                                  ▼                  │
│     ┌─────────────┐    Visualization   ┌─────────────────────┐       │
│     │   GRAFANA   │ ◀───────────────── │   PROMETHEUS        │       │
│     │(Dashboards) │                    │   (Storage)         │       │
│     └─────────────┘                    └─────────────────────┘       │
│                                                                     │
│  3. SECRETS MANAGEMENT                                              │
│                                                                     │
│     ┌─────────────┐  Managed Identity  ┌─────────────────────┐       │
│     │CONTAINER APP│ ─────────────────▶ │   AZURE KEY VAULT   │       │
│     │             │                    │   (Secrets Store)   │       │
│     └─────────────┘                    └─────────────────────┘       │
│                                                                     │
│     Benefits:                                                       │
│     • No secrets in code or configuration                          │
│     • Automatic credential rotation                                │
│     • Centralized access control                                   │
│     • Audit trail for all secret access                            │
│     • Zero-trust security model                                    │
└─────────────────────────────────────────────────────────────────────┘
```

## DISASTER RECOVERY E HIGH AVAILABILITY

```
┌─────────────────────────────────────────────────────────────────────┐
│                     DISASTER RECOVERY STRATEGY                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  PRIMARY REGION: Brazil South                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    ACTIVE SERVICES                         │   │
│  │                                                            │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐    │   │
│  │  │  KEYCLOAK   │  │ PROMETHEUS  │  │   DATABASES     │    │   │
│  │  │  (Primary)  │  │ (Primary)   │  │   (Primary)     │    │   │
│  │  │             │  │             │  │                 │    │   │
│  │  │ • Active    │  │ • Active    │  │ • SQL: Active   │    │   │
│  │  │ • RTO: 30s  │  │ • RTO: 60s  │  │ • PSQL: Active  │    │   │
│  │  │ • RPO: 0    │  │ • RPO: 15m  │  │ • RTO: 4h       │    │   │
│  │  └─────────────┘  └─────────────┘  │ • RPO: 1h       │    │   │
│  │                                    └─────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                │                                    │
│                                ▼ (Continuous Replication)           │
│                                                                     │
│  SECONDARY REGION: Brazil Southeast                                │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   STANDBY SERVICES                         │   │
│  │                                                            │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐    │   │
│  │  │  KEYCLOAK   │  │ PROMETHEUS  │  │   DATABASES     │    │   │
│  │  │  (Standby)  │  │ (Standby)   │  │   (Replicas)    │    │   │
│  │  │             │  │             │  │                 │    │   │
│  │  │ • Warm      │  │ • Cold      │  │ • SQL: Replica  │    │   │
│  │  │ • Auto-fail │  │ • Manual    │  │ • PSQL: Backup  │    │   │
│  │  │ • Config    │  │ • Restore   │  │ • Geo-replicas  │    │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  FAILOVER TRIGGERS:                                                 │
│  • Health endpoint failures (3 consecutive)                        │
│  • Database connectivity loss (>5 minutes)                         │
│  • Region-wide outage detection                                    │
│  • Manual failover command                                         │
│                                                                     │
│  RECOVERY PROCEDURES:                                               │
│  1. Automatic DNS failover                                         │
│  2. Container Apps restart in secondary region                     │
│  3. Database failover (automatic for HA)                           │
│  4. Verify application functionality                               │
│  5. Monitor and alert stakeholders                                 │
└─────────────────────────────────────────────────────────────────────┘
```

**ARQUITETURA DE SISTEMAS ENTERPRISE COM IDENTITY MANAGEMENT E OBSERVABILIDADE COMPLETA**
