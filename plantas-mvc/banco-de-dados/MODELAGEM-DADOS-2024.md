# MODELAGEM DE DADOS - INFRAESTRUTURA 2024

## VISAO GERAL DA ARQUITETURA DE DADOS

### Estrategia Multi-Database
```
                    ┌─────────────────────────────────────┐
                    │         APPLICATION LAYER           │
                    │                                     │
                    │  ┌─────────────┐ ┌─────────────┐   │
                    │  │   KEYCLOAK  │ │    APPS     │   │
                    │  │  (Identity) │ │ (Business)  │   │
                    │  └─────┬───────┘ └─────┬───────┘   │
                    └────────┼─────────────────┼─────────┘
                             │                 │
                ┌────────────▼─────────────────▼────────────┐
                │            DATABASE LAYER                │
                │                                          │
                │  ┌──────────────┐    ┌─────────────────┐ │
                │  │ POSTGRESQL   │    │   SQL SERVER    │ │
                │  │  (Identity)  │    │  (Applications) │ │
                │  │              │    │                 │ │
                │  │ • Keycloak   │    │ • Business Data │ │
                │  │ • Users      │    │ • Transactions  │ │
                │  │ • Roles      │    │ • Analytics     │ │
                │  │ • Sessions   │    │ • Reporting     │ │
                │  └──────────────┘    └─────────────────┘ │
                └──────────────────────────────────────────┘
```

## SQL SERVER - BUSINESS APPLICATIONS

### Configuracao por Ambiente
```
┌─────────────────────────────────────────────────────────────────────┐
│                      SQL SERVER MATRIX                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  DESENVOLVIMENTO (dev-sqlsrv-min)                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • Tier: Basic (5 DTU)                                      │   │
│  │ • Storage: 2GB                                             │   │
│  │ • Backup: 7 days                                           │   │
│  │ • Geo-Replication: Disabled                                │   │
│  │ • Advanced Security: Basic                                 │   │
│  │ • Cost: ~R$ 100/month                                      │   │
│  │                                                            │   │
│  │ Optimal for:                                               │   │
│  │ - Development testing                                      │   │
│  │ - Small datasets                                           │   │
│  │ - Non-critical workloads                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  HOMOLOGACAO (hml-sqlsrv-min)                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • Tier: Standard S0 (10 DTU)                               │   │
│  │ • Storage: 250GB                                           │   │
│  │ • Backup: 30 days                                          │   │
│  │ • Geo-Replication: Read replica                            │   │
│  │ • Advanced Security: Standard                              │   │
│  │ • Cost: ~R$ 400/month                                      │   │
│  │                                                            │   │
│  │ Optimal for:                                               │   │
│  │ - Performance testing                                      │   │
│  │ - Integration testing                                      │   │
│  │ - User acceptance testing                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  PRODUCAO (prd-sqlsrv-enterprise)                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • Tier: Premium P1 (125 DTU)                               │   │
│  │ • Storage: 1TB                                             │   │
│  │ • Backup: 90 days + LTR                                    │   │
│  │ • Geo-Replication: Active                                  │   │
│  │ • Advanced Security: Full                                  │   │
│  │ • Cost: ~R$ 1500/month                                     │   │
│  │                                                            │   │
│  │ Optimal for:                                               │   │
│  │ - High performance                                         │   │
│  │ - Mission critical                                         │   │
│  │ - Enterprise workloads                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Schema de Dados Empresariais
```
┌─────────────────────────────────────────────────────────────────────┐
│                     BUSINESS DATA SCHEMA                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  DATABASE: BusinessData                                             │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      CORE TABLES                           │   │
│  │                                                            │   │
│  │  Users (Business Users)                                    │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ KeycloakUserId (FK to Keycloak)                       │   │
│  │  ├─ Email                                                  │   │
│  │  ├─ Department                                             │   │
│  │  ├─ Role                                                   │   │
│  │  ├─ CreatedAt                                              │   │
│  │  └─ UpdatedAt                                              │   │
│  │                                                            │   │
│  │  Organizations                                             │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ Name                                                   │   │
│  │  ├─ TenantId                                               │   │
│  │  ├─ Settings (JSON)                                        │   │
│  │  ├─ CreatedAt                                              │   │
│  │  └─ IsActive                                               │   │
│  │                                                            │   │
│  │  Projects                                                  │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ OrganizationId (FK)                                    │   │
│  │  ├─ Name                                                   │   │
│  │  ├─ Description                                            │   │
│  │  ├─ Budget                                                 │   │
│  │  ├─ StartDate                                              │   │
│  │  ├─ EndDate                                                │   │
│  │  └─ Status                                                 │   │
│  │                                                            │   │
│  │  Transactions                                              │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ ProjectId (FK)                                         │   │
│  │  ├─ UserId (FK)                                            │   │
│  │  ├─ Amount                                                 │   │
│  │  ├─ Currency                                               │   │
│  │  ├─ Category                                               │   │
│  │  ├─ Description                                            │   │
│  │  ├─ TransactionDate                                        │   │
│  │  └─ CreatedAt                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    AUDIT TABLES                            │   │
│  │                                                            │   │
│  │  AuditLog                                                  │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ TableName                                              │   │
│  │  ├─ RecordId                                               │   │
│  │  ├─ Action (INSERT/UPDATE/DELETE)                          │   │
│  │  ├─ OldValues (JSON)                                       │   │
│  │  ├─ NewValues (JSON)                                       │   │
│  │  ├─ UserId                                                 │   │
│  │  ├─ IPAddress                                              │   │
│  │  ├─ UserAgent                                              │   │
│  │  └─ Timestamp                                              │   │
│  │                                                            │   │
│  │  SecurityEvents                                            │   │
│  │  ├─ Id (PK)                                                │   │
│  │  ├─ EventType                                              │   │
│  │  ├─ Severity                                               │   │
│  │  ├─ Description                                            │   │
│  │  ├─ UserId                                                 │   │
│  │  ├─ IPAddress                                              │   │
│  │  ├─ SourceSystem                                           │   │
│  │  └─ Timestamp                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## POSTGRESQL - KEYCLOAK IDENTITY STORE

### Configuracao Keycloak Database
```
┌─────────────────────────────────────────────────────────────────────┐
│                    POSTGRESQL FOR KEYCLOAK                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FLEXIBLE SERVER CONFIGURATION                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • Version: PostgreSQL 15                                   │   │
│  │ • Compute: Burstable B1ms (1 core, 2GB RAM)                │   │
│  │ • Storage: 32GB GP SSD (auto-growth enabled)               │   │
│  │ • Backup: 7 days (dev) / 30 days (prod)                    │   │
│  │ • High Availability: Zone redundant (prod only)            │   │
│  │ • SSL: Required (TLS 1.2+)                                 │   │
│  │ • Private Network: VNet integrated                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  KEYCLOAK SCHEMA TABLES                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  REALMS & CLIENTS                                          │   │
│  │  ├─ realm                                                  │   │
│  │  ├─ client                                                 │   │
│  │  ├─ client_scope                                           │   │
│  │  ├─ protocol_mapper                                        │   │
│  │  └─ client_session                                         │   │
│  │                                                            │   │
│  │  USERS & AUTHENTICATION                                    │   │
│  │  ├─ user_entity                                            │   │
│  │  ├─ user_attribute                                         │   │
│  │  ├─ credential                                             │   │
│  │  ├─ user_session                                           │   │
│  │  └─ authentication_execution                               │   │
│  │                                                            │   │
│  │  AUTHORIZATION & ROLES                                     │   │
│  │  ├─ keycloak_role                                          │   │
│  │  ├─ user_role_mapping                                      │   │
│  │  ├─ group_role_mapping                                     │   │
│  │  ├─ resource_server                                        │   │
│  │  └─ policy                                                 │   │
│  │                                                            │   │
│  │  FEDERATION & IDENTITY                                     │   │
│  │  ├─ identity_provider                                      │   │
│  │  ├─ federated_identity                                     │   │
│  │  ├─ user_federation_provider                               │   │
│  │  └─ identity_provider_mapper                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### Identity Data Flow
```
┌─────────────────────────────────────────────────────────────────────┐
│                      IDENTITY DATA FLOW                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. USER REGISTRATION                                               │
│     ┌──────────────┐     CREATE      ┌─────────────────┐           │
│     │   FRONTEND   │ ──────────────▶ │    KEYCLOAK     │           │
│     │  (Register)  │                 │   (PostgreSQL)  │           │
│     └──────────────┘                 └─────────┬───────┘           │
│                                                │                   │
│                                                ▼                   │
│                                      ┌─────────────────┐           │
│                                      │  BUSINESS APP   │           │
│                                      │  (SQL Server)   │           │
│                                      └─────────────────┘           │
│                                                                     │
│  2. AUTHENTICATION                                                  │
│     ┌──────────────┐     LOGIN       ┌─────────────────┐           │
│     │   FRONTEND   │ ──────────────▶ │    KEYCLOAK     │           │
│     │   (Login)    │                 │   (Validate)    │           │
│     └──────────────┘                 └─────────┬───────┘           │
│                                                │                   │
│                                                ▼                   │
│                                      ┌─────────────────┐           │
│                                      │   JWT TOKEN     │           │
│                                      │   (Response)    │           │
│                                      └─────────────────┘           │
│                                                                     │
│  3. AUTHORIZATION                                                   │
│     ┌──────────────┐   JWT TOKEN     ┌─────────────────┐           │
│     │   FRONTEND   │ ──────────────▶ │  BUSINESS APP   │           │
│     │ (API Call)   │                 │   (Validate)    │           │
│     └──────────────┘                 └─────────┬───────┘           │
│                                                │                   │
│                                                ▼                   │
│                                      ┌─────────────────┐           │
│                                      │   SQL SERVER    │           │
│                                      │  (Business)     │           │
│                                      └─────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
```

## BACKUP E DISASTER RECOVERY

### Estrategia de Backup
```
┌─────────────────────────────────────────────────────────────────────┐
│                      BACKUP STRATEGY                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  SQL SERVER BACKUP                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  AUTOMATED BACKUPS                                         │   │
│  │  ├─ Full Backup: Daily at 2 AM                            │   │
│  │  ├─ Differential: Every 6 hours                           │   │
│  │  ├─ Transaction Log: Every 15 minutes                     │   │
│  │  └─ Point-in-Time Recovery: 35 days                       │   │
│  │                                                            │   │
│  │  GEO-REPLICATION                                           │   │
│  │  ├─ Primary: Brazil South                                 │   │
│  │  ├─ Secondary: Brazil Southeast                           │   │
│  │  ├─ Read Replica: Available                               │   │
│  │  └─ Failover: Automatic/Manual                            │   │
│  │                                                            │   │
│  │  LONG-TERM RETENTION                                       │   │
│  │  ├─ Weekly: 52 weeks                                      │   │
│  │  ├─ Monthly: 60 months                                    │   │
│  │  ├─ Yearly: 10 years                                      │   │
│  │  └─ Storage: RA-GRS                                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  POSTGRESQL BACKUP                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  FLEXIBLE SERVER BACKUP                                    │   │
│  │  ├─ Full Backup: Daily                                     │   │
│  │  ├─ WAL Backup: Continuous                                │   │
│  │  ├─ Retention: 7-35 days                                  │   │
│  │  └─ Point-in-Time: Any second                             │   │
│  │                                                            │   │
│  │  HIGH AVAILABILITY                                         │   │
│  │  ├─ Zone Redundant: Production                            │   │
│  │  ├─ Standby Replica: Same region                          │   │
│  │  ├─ Failover Time: < 60 seconds                           │   │
│  │  └─ Data Loss: Zero (RPO = 0)                             │   │
│  │                                                            │   │
│  │  CROSS-REGION BACKUP                                       │   │
│  │  ├─ Manual pg_dump: Weekly                                │   │
│  │  ├─ Storage Account: Geo-redundant                        │   │
│  │  ├─ Automation: Azure Functions                           │   │
│  │  └─ Monitoring: Azure Monitor                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## SECURITY IMPLEMENTATION

### Database Security
```
┌─────────────────────────────────────────────────────────────────────┐
│                      DATABASE SECURITY                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ENCRYPTION                                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • TDE (Transparent Data Encryption): All databases         │   │
│  │ • Encryption at Rest: AES-256                              │   │
│  │ • Encryption in Transit: TLS 1.3                           │   │
│  │ • Key Management: Azure Key Vault                          │   │
│  │ • Certificate Auto-Rotation: Enabled                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ACCESS CONTROL                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • Azure AD Authentication: Preferred                       │   │
│  │ • SQL Authentication: Emergency only                       │   │
│  │ • Managed Identity: Application access                     │   │
│  │ • RBAC: Least privilege principle                          │   │
│  │ • Network Access: Private endpoints only                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  MONITORING & AUDITING                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • SQL Audit: All operations logged                         │   │
│  │ • Advanced Threat Protection: Enabled                      │   │
│  │ • Vulnerability Assessment: Weekly scans                   │   │
│  │ • Log Analytics: Centralized logging                       │   │
│  │ • Alerts: Anomaly detection                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  COMPLIANCE                                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ • LGPD: Personal data protection                           │   │
│  │ • SOC 2: Security controls                                 │   │
│  │ • ISO 27001: Information security                          │   │
│  │ • OWASP: Secure development practices                      │   │
│  │ • Audit Reports: Quarterly generation                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## PERFORMANCE OPTIMIZATION

### Database Tuning
```
┌─────────────────────────────────────────────────────────────────────┐
│                   PERFORMANCE OPTIMIZATION                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  SQL SERVER OPTIMIZATION                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  INDEXING STRATEGY                                         │   │
│  │  ├─ Clustered Indexes: Primary keys                       │   │
│  │  ├─ Non-Clustered: Foreign keys, search columns           │   │
│  │  ├─ Covering Indexes: Frequent queries                    │   │
│  │  ├─ Filtered Indexes: Sparse data                         │   │
│  │  └─ Maintenance: Weekly rebuild/reorganize                │   │
│  │                                                            │   │
│  │  QUERY OPTIMIZATION                                        │   │
│  │  ├─ Query Store: Enabled                                  │   │
│  │  ├─ Execution Plans: Cached                               │   │
│  │  ├─ Statistics: Auto-update                               │   │
│  │  ├─ Parameterization: Forced                              │   │
│  │  └─ Query Timeout: 30 seconds                             │   │
│  │                                                            │   │
│  │  CONNECTION POOLING                                        │   │
│  │  ├─ Max Pool Size: 100                                    │   │
│  │  ├─ Min Pool Size: 5                                      │   │
│  │  ├─ Connection Timeout: 15 seconds                        │   │
│  │  ├─ Command Timeout: 30 seconds                           │   │
│  │  └─ Retry Logic: Exponential backoff                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  POSTGRESQL OPTIMIZATION                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  CONFIGURATION TUNING                                      │   │
│  │  ├─ shared_buffers: 25% of RAM                            │   │
│  │  ├─ effective_cache_size: 75% of RAM                      │   │
│  │  ├─ work_mem: 4MB per connection                          │   │
│  │  ├─ maintenance_work_mem: 64MB                            │   │
│  │  └─ max_connections: 100                                  │   │
│  │                                                            │   │
│  │  VACUUM & ANALYZE                                          │   │
│  │  ├─ Auto-vacuum: Enabled                                  │   │
│  │  ├─ Analyze: After 10% changes                            │   │
│  │  ├─ Vacuum: After 20% changes                             │   │
│  │  ├─ Vacuum Freeze: Monthly                                │   │
│  │  └─ Statistics: Real-time                                 │   │
│  │                                                            │   │
│  │  LOGGING & MONITORING                                      │   │
│  │  ├─ log_statement: 'all'                                  │   │
│  │  ├─ log_duration: 'on'                                    │   │
│  │  ├─ log_min_duration: 1000ms                              │   │
│  │  ├─ pg_stat_statements: Enabled                           │   │
│  │  └─ Query Performance Insights: Active                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## MONITORING & ALERTING

### Database Monitoring
```
┌─────────────────────────────────────────────────────────────────────┐
│                    DATABASE MONITORING                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  KEY METRICS                                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  PERFORMANCE METRICS                                       │   │
│  │  ├─ CPU Utilization: < 80%                                │   │
│  │  ├─ Memory Usage: < 85%                                   │   │
│  │  ├─ Storage Usage: < 80%                                  │   │
│  │  ├─ IOPS: Within tier limits                              │   │
│  │  └─ Connection Count: < 80% of max                        │   │
│  │                                                            │   │
│  │  QUERY METRICS                                             │   │
│  │  ├─ Average Response Time: < 100ms                        │   │
│  │  ├─ Slow Queries: < 1% of total                           │   │
│  │  ├─ Failed Queries: < 0.1%                                │   │
│  │  ├─ Deadlocks: < 1 per hour                               │   │
│  │  └─ Blocking Processes: < 5 seconds                       │   │
│  │                                                            │   │
│  │  AVAILABILITY METRICS                                      │   │
│  │  ├─ Uptime: > 99.9%                                       │   │
│  │  ├─ Backup Success: 100%                                  │   │
│  │  ├─ Replication Lag: < 5 seconds                          │   │
│  │  ├─ Failover Time: < 30 seconds                           │   │
│  │  └─ Recovery Time: < 4 hours                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ALERTING RULES                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                            │   │
│  │  CRITICAL ALERTS (Immediate Response)                      │   │
│  │  ├─ Database Down: PagerDuty + SMS                        │   │
│  │  ├─ High CPU: > 90% for 5 minutes                         │   │
│  │  ├─ Storage Full: > 95% used                              │   │
│  │  ├─ Connection Limit: > 95% of max                        │   │
│  │  └─ Backup Failed: Email + Slack                          │   │
│  │                                                            │   │
│  │  WARNING ALERTS (Within Business Hours)                   │   │
│  │  ├─ Performance Degradation: > 500ms queries              │   │
│  │  ├─ High Memory: > 85% for 10 minutes                     │   │
│  │  ├─ Storage Growth: > 75% used                            │   │
│  │  ├─ Replication Lag: > 30 seconds                         │   │
│  │  └─ Security Events: Failed logins                        │   │
│  │                                                            │   │
│  │  INFO ALERTS (Daily Reports)                              │   │
│  │  ├─ Performance Summary: Daily email                      │   │
│  │  ├─ Backup Status: Weekly report                          │   │
│  │  ├─ Growth Trends: Monthly analysis                       │   │
│  │  ├─ Security Report: Weekly summary                       │   │
│  │  └─ Cost Analysis: Monthly billing                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

**MODELAGEM DE DADOS ENTERPRISE COM IDENTITY INTEGRATION E OBSERVABILIDADE COMPLETA**
