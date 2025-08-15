# ARQUITETURA DE SEGURANCA - DEFENSE IN DEPTH 2024

## ESTRATEGIA DE SEGURANCA MULTICAMADAS

### Modelo de Security Zero Trust
```
                            THREAT LANDSCAPE
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
            ┌───────▼──────┐      │      ┌───────▼──────┐
            │   EXTERNAL   │      │      │   INTERNAL   │
            │   THREATS    │      │      │   THREATS    │
            └──────────────┘      │      └──────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │      ZERO TRUST CORE      │
                    │                           │
                    │ • Never Trust            │
                    │ • Always Verify          │
                    │ • Least Privilege        │
                    │ • Assume Breach          │
                    └───────────────────────────┘
```

## CAMADA 1: PERIMETER SECURITY

### Internet Edge Protection
```
┌─────────────────────────────────────────────────────────────────────┐
│                      INTERNET EDGE SECURITY                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ AZURE FRONT DOOR ─────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 WAF (WEB APPLICATION FIREWALL)          │  │ │
│  │   │                                                         │  │ │
│  │   │  OWASP Top 10 Protection:                               │  │ │
│  │   │  ├─ SQL Injection                                       │  │ │
│  │   │  ├─ Cross-Site Scripting (XSS)                         │  │ │
│  │   │  ├─ Cross-Site Request Forgery (CSRF)                  │  │ │
│  │   │  ├─ Path Traversal                                     │  │ │
│  │   │  ├─ Remote File Inclusion                              │  │ │
│  │   │  └─ Command Injection                                  │  │ │
│  │   │                                                         │  │ │
│  │   │  Custom Rules:                                          │  │ │
│  │   │  ├─ Rate Limiting: 1000 req/min per IP                 │  │ │
│  │   │  ├─ Geo-blocking: Block known threat countries         │  │ │
│  │   │  ├─ IP Allowlist: Admin access whitelist               │  │ │
│  │   │  ├─ Bot Protection: Challenge suspicious patterns      │  │ │
│  │   │  └─ Size Limits: Max 10MB request payload              │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 DDOS PROTECTION                         │  │ │
│  │   │                                                         │  │ │
│  │   │  Basic Protection (Free):                               │  │ │
│  │   │  ├─ Network Volume Attacks                             │  │ │
│  │   │  ├─ Protocol Attacks                                   │  │ │
│  │   │  ├─ Resource Layer Attacks                             │  │ │
│  │   │  └─ Always-on Monitoring                               │  │ │
│  │   │                                                         │  │ │
│  │   │  Standard Protection (Production):                      │  │ │
│  │   │  ├─ Attack Analytics                                   │  │ │
│  │   │  ├─ Rapid Response Team                                │  │ │
│  │   │  ├─ Cost Protection SLA                                │  │ │
│  │   │  └─ Advanced Metrics                                   │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 SSL/TLS SECURITY                        │  │ │
│  │   │                                                         │  │ │
│  │   │  Certificate Management:                                │  │ │
│  │   │  ├─ Auto-Renewal: Let's Encrypt Integration            │  │ │
│  │   │  ├─ TLS 1.3: Latest protocol version                   │  │ │
│  │   │  ├─ HSTS: HTTP Strict Transport Security               │  │ │
│  │   │  ├─ Certificate Transparency                           │  │ │
│  │   │  └─ Perfect Forward Secrecy                            │  │ │
│  │   │                                                         │  │ │
│  │   │  Cipher Suites:                                         │  │ │
│  │   │  ├─ ECDHE-RSA-AES256-GCM-SHA384                       │  │ │
│  │   │  ├─ ECDHE-RSA-AES128-GCM-SHA256                       │  │ │
│  │   │  ├─ DHE-RSA-AES256-GCM-SHA384                         │  │ │
│  │   │  └─ Block: RC4, MD5, SHA1                              │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## CAMADA 2: NETWORK SECURITY

### Network Isolation and Segmentation
```
┌─────────────────────────────────────────────────────────────────────┐
│                      NETWORK SECURITY LAYERS                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ VIRTUAL NETWORK ISOLATION ────────────────────────────────────┐ │
│  │                                                                │ │
│  │   DEV VNET (10.100.0.0/16)                                    │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Container Apps Subnet: 10.100.1.0/24                   │  │ │
│  │   │ Database Subnet:       10.100.2.0/24                   │  │ │
│  │   │ Private Endpoints:     10.100.3.0/24                   │  │ │
│  │   │ Management:            10.100.4.0/24                   │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   HOMOLOG VNET (10.200.0.0/16)                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Container Apps Subnet: 10.200.1.0/24                   │  │ │
│  │   │ Database Subnet:       10.200.2.0/24                   │  │ │
│  │   │ Private Endpoints:     10.200.3.0/24                   │  │ │
│  │   │ Management:            10.200.4.0/24                   │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ISOLATION RULES:                                             │ │
│  │   • No VNet Peering between environments                      │ │
│  │   • Separate DNS zones                                        │ │
│  │   • Independent routing tables                                │ │
│  │   • Environment-specific service endpoints                    │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ NETWORK SECURITY GROUPS (NSG) ────────────────────────────────┐ │
│  │                                                                │ │
│  │   CONTAINER APPS NSG RULES:                                   │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Priority  │ Direction │ Action │ Protocol │ Port │ Source│  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ 100       │ Inbound   │ Allow  │ HTTPS    │ 443  │ *     │  │ │
│  │   │ 110       │ Inbound   │ Allow  │ HTTP     │ 80   │ *     │  │ │
│  │   │ 120       │ Inbound   │ Allow  │ TCP      │ 8080 │ VNet  │  │ │
│  │   │ 130       │ Inbound   │ Allow  │ TCP      │ 9090 │ VNet  │  │ │
│  │   │ 4000      │ Inbound   │ Deny   │ *        │ *    │ *     │  │ │
│  │   │ 100       │ Outbound  │ Allow  │ HTTPS    │ 443  │ *     │  │ │
│  │   │ 110       │ Outbound  │ Allow  │ TCP      │ 1433 │ DB    │  │ │
│  │   │ 120       │ Outbound  │ Allow  │ TCP      │ 5432 │ DB    │  │ │
│  │   │ 4000      │ Outbound  │ Deny   │ *        │ *    │ *     │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   DATABASE NSG RULES:                                          │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Priority  │ Direction │ Action │ Protocol │ Port │ Source│  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ 100       │ Inbound   │ Allow  │ TCP      │ 1433 │ Apps  │  │ │
│  │   │ 110       │ Inbound   │ Allow  │ TCP      │ 5432 │ Apps  │  │ │
│  │   │ 120       │ Inbound   │ Allow  │ TCP      │ 443  │ Mgmt  │  │ │
│  │   │ 4000      │ Inbound   │ Deny   │ *        │ *    │ *     │  │ │
│  │   │ 100       │ Outbound  │ Allow  │ HTTPS    │ 443  │ *     │  │ │
│  │   │ 4000      │ Outbound  │ Deny   │ *        │ *    │ *     │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ PRIVATE ENDPOINTS ─────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   CONFIGURATION:                                               │ │
│  │   ├─ SQL Server: Private endpoint only                        │ │
│  │   ├─ PostgreSQL: VNet integrated                               │ │
│  │   ├─ Key Vault: Private endpoint + firewall                   │ │
│  │   ├─ Storage: Private endpoint for blobs                      │ │
│  │   └─ Container Registry: Private endpoint                     │ │
│  │                                                                │ │
│  │   BENEFITS:                                                    │ │
│  │   • No public internet exposure                               │ │
│  │   • Traffic stays within Azure backbone                       │ │
│  │   • DNS integration for name resolution                       │ │
│  │   • Network policies applied                                  │ │
│  │   • Audit logs for all connections                            │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## CAMADA 3: IDENTITY & ACCESS MANAGEMENT

### Comprehensive Identity Security
```
┌─────────────────────────────────────────────────────────────────────┐
│                     IDENTITY & ACCESS MANAGEMENT                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ KEYCLOAK IDENTITY PROVIDER ───────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 REALM CONFIGURATION                     │  │ │
│  │   │                                                         │  │ │
│  │   │  Master Realm (Administration):                         │  │ │
│  │   │  ├─ Admin Users: Limited to 2-3 users                  │  │ │
│  │   │  ├─ MFA Required: Always enabled                       │  │ │
│  │   │  ├─ Session Timeout: 15 minutes                        │  │ │
│  │   │  ├─ Failed Login: Account lock after 3 attempts       │  │ │
│  │   │  └─ Audit Logging: All actions tracked                │  │ │
│  │   │                                                         │  │ │
│  │   │  Business Realm (Applications):                        │  │ │
│  │   │  ├─ User Self-Registration: Controlled                 │  │ │
│  │   │  ├─ Email Verification: Required                       │  │ │
│  │   │  ├─ Password Policy: Strong requirements               │  │ │
│  │   │  ├─ Social Logins: Google, Microsoft                  │  │ │
│  │   │  └─ Federation: Azure AD integration                  │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 AUTHENTICATION FLOWS                    │  │ │
│  │   │                                                         │  │ │
│  │   │  Standard Flow (Authorization Code):                    │  │ │
│  │   │  ├─ Client redirects to Keycloak                       │  │ │
│  │   │  ├─ User authenticates (username/password + MFA)       │  │ │
│  │   │  ├─ Authorization code returned                        │  │ │
│  │   │  ├─ Client exchanges code for tokens                   │  │ │
│  │   │  └─ Access token used for API calls                    │  │ │
│  │   │                                                         │  │ │
│  │   │  Implicit Flow (SPA):                                   │  │ │
│  │   │  ├─ Disabled for security                              │  │ │
│  │   │  └─ PKCE required for public clients                   │  │ │
│  │   │                                                         │  │ │
│  │   │  Client Credentials Flow (M2M):                        │  │ │
│  │   │  ├─ Service-to-service authentication                  │  │ │
│  │   │  ├─ Client secret or certificate                       │  │ │
│  │   │  └─ Limited scopes and permissions                     │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ AZURE ACTIVE DIRECTORY INTEGRATION ───────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 FEDERATION SETUP                        │  │ │
│  │   │                                                         │  │ │
│  │   │  SAML 2.0 Configuration:                               │  │ │
│  │   │  ├─ Azure AD as Identity Provider                      │  │ │
│  │   │  ├─ Keycloak as Service Provider                       │  │ │
│  │   │  ├─ Assertion Signed and Encrypted                     │  │ │
│  │   │  ├─ Attribute Mapping (email, groups, roles)           │  │ │
│  │   │  └─ Just-In-Time provisioning                          │  │ │
│  │   │                                                         │  │ │
│  │   │  OpenID Connect Configuration:                         │  │ │
│  │   │  ├─ Client ID and Secret from Azure AD                 │  │ │
│  │   │  ├─ Scopes: openid, profile, email                    │  │ │
│  │   │  ├─ Claims mapping for user attributes                 │  │ │
│  │   │  ├─ Group claims for role assignment                   │  │ │
│  │   │  └─ Conditional Access policies applied                │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 CONDITIONAL ACCESS                      │  │ │
│  │   │                                                         │  │ │
│  │   │  Device Compliance:                                     │  │ │
│  │   │  ├─ Managed devices only (Intune)                      │  │ │
│  │   │  ├─ OS version requirements                            │  │ │
│  │   │  ├─ Anti-malware protection                            │  │ │
│  │   │  └─ Device encryption required                         │  │ │
│  │   │                                                         │  │ │
│  │   │  Location-Based Access:                                 │  │ │
│  │   │  ├─ Trusted locations defined                          │  │ │
│  │   │  ├─ Block access from risky countries                  │  │ │
│  │   │  ├─ VPN requirements for remote access                 │  │ │
│  │   │  └─ Named locations for offices                        │  │ │
│  │   │                                                         │  │ │
│  │   │  Risk-Based Access:                                     │  │ │
│  │   │  ├─ User risk assessment (Azure AD Identity Protection)│  │ │
│  │   │  ├─ Sign-in risk evaluation                            │  │ │
│  │   │  ├─ Automatic remediation (password reset, MFA)        │  │ │
│  │   │  └─ Block high-risk sign-ins                           │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ ROLE-BASED ACCESS CONTROL (RBAC) ─────────────────────────────┐ │
│  │                                                                │ │
│  │   APPLICATION ROLES:                                           │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Role Name        │ Permissions                         │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ Super Admin      │ Full system access                  │  │ │
│  │   │ Organization Admin│ Manage org users and settings      │  │ │
│  │   │ Project Manager  │ Create/manage projects             │  │ │
│  │   │ Finance Manager  │ View/manage financial data         │  │ │
│  │   │ Auditor          │ Read-only access to all data       │  │ │
│  │   │ Standard User    │ Basic application features          │  │ │
│  │   │ Guest User       │ Limited read-only access            │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   AZURE RBAC (Infrastructure):                                 │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Role Name           │ Scope                             │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ Owner               │ Production subscription only      │  │ │
│  │   │ Contributor         │ Dev/Homolog resource groups       │  │ │
│  │   │ Reader              │ All environments (monitoring)     │  │ │
│  │   │ Key Vault Admin     │ Key Vault resources only          │  │ │
│  │   │ SQL DB Contributor  │ Database resources only           │  │ │
│  │   │ Monitoring Reader   │ Metrics and logs                  │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## CAMADA 4: DATA SECURITY

### Comprehensive Data Protection
```
┌─────────────────────────────────────────────────────────────────────┐
│                        DATA SECURITY LAYERS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ ENCRYPTION STRATEGY ──────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 ENCRYPTION AT REST                      │  │ │
│  │   │                                                         │  │ │
│  │   │  SQL Server:                                            │  │ │
│  │   │  ├─ TDE (Transparent Data Encryption): AES-256         │  │ │
│  │   │  ├─ Service-managed keys (default)                     │  │ │
│  │   │  ├─ Customer-managed keys (production)                 │  │ │
│  │   │  ├─ Backup encryption: AES-256                         │  │ │
│  │   │  └─ Always Encrypted for sensitive columns             │  │ │
│  │   │                                                         │  │ │
│  │   │  PostgreSQL:                                            │  │ │
│  │   │  ├─ Server-side encryption: AES-256                    │  │ │
│  │   │  ├─ Azure Key Vault integration                        │  │ │
│  │   │  ├─ Backup encryption: Automatic                       │  │ │
│  │   │  └─ SSL enforcement: Required                          │  │ │
│  │   │                                                         │  │ │
│  │   │  Storage Accounts:                                      │  │ │
│  │   │  ├─ Blob encryption: AES-256                           │  │ │
│  │   │  ├─ Customer-managed keys                              │  │ │
│  │   │  ├─ Infrastructure encryption (double encryption)      │  │ │
│  │   │  └─ Soft delete and versioning enabled                │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                ENCRYPTION IN TRANSIT                   │  │ │
│  │   │                                                         │  │ │
│  │   │  Application Layer:                                     │  │ │
│  │   │  ├─ HTTPS only (TLS 1.3)                               │  │ │
│  │   │  ├─ HTTP Strict Transport Security (HSTS)              │  │ │
│  │   │  ├─ Certificate transparency                           │  │ │
│  │   │  └─ Perfect Forward Secrecy                            │  │ │
│  │   │                                                         │  │ │
│  │   │  Database Connections:                                  │  │ │
│  │   │  ├─ SQL Server: Encrypt=True, TrustServerCertificate   │  │ │
│  │   │  ├─ PostgreSQL: sslmode=require                        │  │ │
│  │   │  ├─ Connection pooling over TLS                        │  │ │
│  │   │  └─ Certificate validation enabled                     │  │ │
│  │   │                                                         │  │ │
│  │   │  Internal Communications:                               │  │ │
│  │   │  ├─ Container-to-container: mTLS                       │  │ │
│  │   │  ├─ Service mesh encryption                            │  │ │
│  │   │  ├─ API calls: Bearer token over HTTPS                │  │ │
│  │   │  └─ Monitoring data: TLS encryption                    │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ KEY MANAGEMENT ───────────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                 AZURE KEY VAULT                         │  │ │
│  │   │                                                         │  │ │
│  │   │  Key Types:                                             │  │ │
│  │   │  ├─ RSA Keys: 2048-bit minimum                          │  │ │
│  │   │  ├─ ECDSA Keys: P-256 curve                            │  │ │
│  │   │  ├─ AES Keys: 256-bit for symmetric encryption         │  │ │
│  │   │  └─ HSM-backed keys for production                     │  │ │
│  │   │                                                         │  │ │
│  │   │  Secrets Management:                                    │  │ │
│  │   │  ├─ Connection strings                                 │  │ │
│  │   │  ├─ API keys and tokens                                │  │ │
│  │   │  ├─ Certificates and passwords                         │  │ │
│  │   │  └─ Versioning and history tracking                    │  │ │
│  │   │                                                         │  │ │
│  │   │  Access Policies:                                       │  │ │
│  │   │  ├─ Managed Identity for Container Apps                │  │ │
│  │   │  ├─ RBAC for human access                              │  │ │
│  │   │  ├─ Network restrictions (VNet only)                   │  │ │
│  │   │  ├─ Audit logging for all operations                   │  │ │
│  │   │  └─ Soft delete and purge protection                   │  │ │
│  │   │                                                         │  │ │
│  │   │  Key Rotation:                                          │  │ │
│  │   │  ├─ Automatic rotation: 90 days                        │  │ │
│  │   │  ├─ Grace period: 30 days for old keys                 │  │ │
│  │   │  ├─ Notification alerts                                │  │ │
│  │   │  └─ Zero-downtime rotation process                     │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ DATA CLASSIFICATION & PROTECTION ─────────────────────────────┐ │
│  │                                                                │ │
│  │   DATA CLASSIFICATION LEVELS:                                  │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Level       │ Description            │ Protection       │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ Public      │ No restriction         │ Standard backup  │  │ │
│  │   │ Internal    │ Company confidential   │ Encryption + Log │  │ │
│  │   │ Confidential│ Limited access         │ MFA + Audit      │  │ │
│  │   │ Restricted  │ Highly sensitive       │ HSM + DLP        │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   PERSONAL DATA (LGPD/GDPR):                                   │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Data Type         │ Protection Measures                 │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ PII               │ Field-level encryption              │  │ │
│  │   │ Financial         │ Tokenization + HSM                  │  │ │
│  │   │ Health            │ Always Encrypted columns            │  │ │
│  │   │ Biometric         │ Hash + salt storage                 │  │ │
│  │   │ Location          │ Anonymization techniques            │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   DATA LOSS PREVENTION (DLP):                                  │ │
│  │   ├─ Content inspection and classification                     │ │
│  │   ├─ Policy enforcement at data boundaries                     │ │
│  │   ├─ Real-time blocking of sensitive data                      │ │
│  │   ├─ User education and notifications                          │ │
│  │   └─ Compliance reporting and auditing                        │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## CAMADA 5: APPLICATION SECURITY

### Secure Development and Runtime Protection
```
┌─────────────────────────────────────────────────────────────────────┐
│                     APPLICATION SECURITY                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ SECURE DEVELOPMENT LIFECYCLE (SDL) ───────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                DESIGN PHASE                             │  │ │
│  │   │                                                         │  │ │
│  │   │  Security Requirements:                                 │  │ │
│  │   │  ├─ Threat modeling (STRIDE methodology)               │  │ │
│  │   │  ├─ Security architecture review                       │  │ │
│  │   │  ├─ Privacy impact assessment                          │  │ │
│  │   │  ├─ Compliance requirements mapping                    │  │ │
│  │   │  └─ Security controls specification                    │  │ │
│  │   │                                                         │  │ │
│  │   │  Attack Surface Analysis:                               │  │ │
│  │   │  ├─ Entry points identification                        │  │ │
│  │   │  ├─ Trust boundaries definition                        │  │ │
│  │   │  ├─ Data flow analysis                                 │  │ │
│  │   │  └─ Asset valuation and risk assessment                │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │               DEVELOPMENT PHASE                         │  │ │
│  │   │                                                         │  │ │
│  │   │  Secure Coding Standards:                               │  │ │
│  │   │  ├─ OWASP Secure Coding Practices                      │  │ │
│  │   │  ├─ Input validation and sanitization                  │  │ │
│  │   │  ├─ Output encoding and escaping                       │  │ │
│  │   │  ├─ Parameterized queries (SQL injection prevention)   │  │ │
│  │   │  ├─ CSRF tokens for state-changing operations          │  │ │
│  │   │  └─ Secure session management                          │  │ │
│  │   │                                                         │  │ │
│  │   │  Static Application Security Testing (SAST):           │  │ │
│  │   │  ├─ Automated code analysis in CI/CD                   │  │ │
│  │   │  ├─ SonarQube integration                              │  │ │
│  │   │  ├─ Security hotspots identification                   │  │ │
│  │   │  ├─ Vulnerability severity scoring                     │  │ │
│  │   │  └─ Fix recommendations and guidance                   │  │ │
│  │   │                                                         │  │ │
│  │   │  Dependency Scanning:                                   │  │ │
│  │   │  ├─ Known vulnerability detection                      │  │ │
│  │   │  ├─ License compliance checking                        │  │ │
│  │   │  ├─ Supply chain security validation                   │  │ │
│  │   │  └─ Automated dependency updates                       │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │               DEPLOYMENT PHASE                          │  │ │
│  │   │                                                         │  │ │
│  │   │  Container Security:                                    │  │ │
│  │   │  ├─ Base image vulnerability scanning                  │  │ │
│  │   │  ├─ Minimal attack surface (distroless images)         │  │ │
│  │   │  ├─ Non-root user execution                            │  │ │
│  │   │  ├─ Read-only file systems                             │  │ │
│  │   │  ├─ Resource limits and quotas                         │  │ │
│  │   │  └─ Security context constraints                       │  │ │
│  │   │                                                         │  │ │
│  │   │  Dynamic Application Security Testing (DAST):          │  │ │
│  │   │  ├─ Automated penetration testing                      │  │ │
│  │   │  ├─ Runtime vulnerability assessment                   │  │ │
│  │   │  ├─ API security testing                               │  │ │
│  │   │  ├─ Authentication and authorization testing           │  │ │
│  │   │  └─ Business logic flaw detection                      │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ RUNTIME APPLICATION PROTECTION ───────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │               CONTAINER SECURITY                        │  │ │
│  │   │                                                         │  │ │
│  │   │  Azure Container Apps Security:                         │  │ │
│  │   │  ├─ Managed identity for authentication                │  │ │
│  │   │  ├─ Secrets mounted as environment variables           │  │ │
│  │   │  ├─ Network isolation within VNet                      │  │ │
│  │   │  ├─ Auto-scaling based on demand                       │  │ │
│  │   │  └─ Health probes for availability                     │  │ │
│  │   │                                                         │  │ │
│  │   │  Runtime Protection:                                    │  │ │
│  │   │  ├─ Container image scanning on deployment             │  │ │
│  │   │  ├─ Runtime behavior monitoring                        │  │ │
│  │   │  ├─ Anomaly detection and alerting                     │  │ │
│  │   │  ├─ Process allow-listing                              │  │ │
│  │   │  └─ File integrity monitoring                          │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │              API SECURITY                               │  │ │
│  │   │                                                         │  │ │
│  │   │  Authentication & Authorization:                        │  │ │
│  │   │  ├─ JWT token validation                                │  │ │
│  │   │  ├─ OAuth 2.0 scopes enforcement                       │  │ │
│  │   │  ├─ Rate limiting per user/client                      │  │ │
│  │   │  ├─ Request signing and validation                     │  │ │
│  │   │  └─ API versioning and deprecation                     │  │ │
│  │   │                                                         │  │ │
│  │   │  Input Validation:                                      │  │ │
│  │   │  ├─ Schema-based validation                            │  │ │
│  │   │  ├─ Content-type verification                          │  │ │
│  │   │  ├─ Request size limits                                │  │ │
│  │   │  ├─ SQL injection prevention                           │  │ │
│  │   │  └─ XSS protection headers                             │  │ │
│  │   │                                                         │  │ │
│  │   │  Response Security:                                     │  │ │
│  │   │  ├─ Security headers (CSP, HSTS, etc.)                 │  │ │
│  │   │  ├─ Sensitive data filtering                           │  │ │
│  │   │  ├─ Error message sanitization                         │  │ │
│  │   │  └─ CORS policy enforcement                            │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## CAMADA 6: MONITORING & INCIDENT RESPONSE

### Security Operations Center (SOC)
```
┌─────────────────────────────────────────────────────────────────────┐
│                    SECURITY MONITORING & RESPONSE                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ SECURITY INFORMATION & EVENT MANAGEMENT (SIEM) ───────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │                AZURE SENTINEL                           │  │ │
│  │   │                                                         │  │ │
│  │   │  Data Sources:                                          │  │ │
│  │   │  ├─ Azure Activity Logs                                 │  │ │
│  │   │  ├─ Azure AD Sign-in Logs                               │  │ │
│  │   │  ├─ Network Security Group Flow Logs                   │  │ │
│  │   │  ├─ Application Logs (from Container Apps)              │  │ │
│  │   │  ├─ Key Vault Audit Logs                               │  │ │
│  │   │  ├─ SQL Audit Logs                                     │  │ │
│  │   │  ├─ Keycloak Authentication Events                     │  │ │
│  │   │  └─ Threat Intelligence Feeds                          │  │ │
│  │   │                                                         │  │ │
│  │   │  Analytics Rules:                                       │  │ │
│  │   │  ├─ Failed login attempts (>5 in 15 minutes)           │  │ │
│  │   │  ├─ Privilege escalation attempts                      │  │ │
│  │   │  ├─ Unusual data access patterns                       │  │ │
│  │   │  ├─ Suspicious network traffic                         │  │ │
│  │   │  ├─ Malware detection indicators                       │  │ │
│  │   │  └─ Compliance violation patterns                      │  │ │
│  │   │                                                         │  │ │
│  │   │  Automated Response:                                    │  │ │
│  │   │  ├─ Account lockout for brute force                    │  │ │
│  │   │  ├─ IP blocking for malicious sources                  │  │ │
│  │   │  ├─ Incident creation in ticketing system              │  │ │
│  │   │  ├─ Email/SMS alerts to security team                  │  │ │
│  │   │  └─ Containment playbook execution                     │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ VULNERABILITY MANAGEMENT ─────────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │              MICROSOFT DEFENDER                         │  │ │
│  │   │                                                         │  │ │
│  │   │  Cloud Security Posture Management:                    │  │ │
│  │   │  ├─ Configuration assessment                           │  │ │
│  │   │  ├─ Security recommendations                           │  │ │
│  │   │  ├─ Compliance dashboard                               │  │ │
│  │   │  ├─ Resource inventory and classification              │  │ │
│  │   │  └─ Secure score tracking                              │  │ │
│  │   │                                                         │  │ │
│  │   │  Container Security:                                    │  │ │
│  │   │  ├─ Registry vulnerability scanning                    │  │ │
│  │   │  ├─ Runtime threat detection                           │  │ │
│  │   │  ├─ Kubernetes security assessment                     │  │ │
│  │   │  ├─ Supply chain attack protection                     │  │ │
│  │   │  └─ Compliance monitoring                              │  │ │
│  │   │                                                         │  │ │
│  │   │  Database Security:                                     │  │ │
│  │   │  ├─ SQL vulnerability assessment                       │  │ │
│  │   │  ├─ Data discovery and classification                  │  │ │
│  │   │  ├─ Advanced threat protection                         │  │ │
│  │   │  ├─ Anomalous activity detection                       │  │ │
│  │   │  └─ Compliance reporting                               │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ INCIDENT RESPONSE PROCEDURES ─────────────────────────────────┐ │
│  │                                                                │ │
│  │   SEVERITY LEVELS:                                             │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Level    │ Description           │ Response Time        │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ Critical │ Active breach/outage  │ 15 minutes          │  │ │
│  │   │ High     │ Potential breach      │ 1 hour              │  │ │
│  │   │ Medium   │ Security violation    │ 4 hours             │  │ │
│  │   │ Low      │ Policy deviation      │ 24 hours            │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   RESPONSE PLAYBOOKS:                                          │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ Incident Type        │ Initial Response                 │  │ │
│  │   ├─────────────────────────────────────────────────────────┤  │ │
│  │   │ Data Breach          │ Isolate, assess, notify         │  │ │
│  │   │ Malware Detection    │ Contain, analyze, eradicate     │  │ │
│  │   │ DDoS Attack          │ Mitigate, scale, investigate    │  │ │
│  │   │ Insider Threat       │ Disable access, collect evidence│  │ │
│  │   │ System Compromise    │ Isolate, image, analyze         │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   POST-INCIDENT ACTIVITIES:                                    │ │
│  │   ├─ Forensic analysis and evidence collection                │ │
│  │   ├─ Root cause analysis and timeline reconstruction          │ │
│  │   ├─ Lessons learned and process improvement                  │ │
│  │   ├─ Security control updates and remediation                 │ │
│  │   ├─ Stakeholder communication and reporting                  │ │
│  │   └─ Compliance notification (if required)                    │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## COMPLIANCE & GOVERNANCE

### Regulatory Compliance Framework
```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPLIANCE & GOVERNANCE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ REGULATORY COMPLIANCE ─────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   LGPD (Lei Geral de Proteção de Dados):                       │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ • Data mapping and inventory                            │  │ │
│  │   │ • Consent management system                             │  │ │
│  │   │ • Data subject rights (access, rectification, erasure) │  │ │
│  │   │ • Privacy impact assessments                           │  │ │
│  │   │ • Data protection officer (DPO) designation            │  │ │
│  │   │ • Breach notification procedures (72 hours)            │  │ │
│  │   │ • Cross-border transfer safeguards                     │  │ │
│  │   │ • Regular compliance audits and reviews                │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   SOC 2 Type II Compliance:                                    │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ • Security: Logical and physical access controls       │  │ │
│  │   │ • Availability: System uptime and performance          │  │ │
│  │   │ • Processing Integrity: Accurate and timely processing │  │ │
│  │   │ • Confidentiality: Protected information handling      │  │ │
│  │   │ • Privacy: Personal information collection and use     │  │ │
│  │   │ • Independent auditor assessment                       │  │ │
│  │   │ • Continuous monitoring and improvement                │  │ │
│  │   │ • Annual attestation reports                           │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ISO 27001 Information Security Management:                   │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │ • Information security management system (ISMS)        │  │ │
│  │   │ • Risk assessment and treatment methodology            │  │ │
│  │   │ • Security policies and procedures                     │  │ │
│  │   │ • Employee training and awareness programs             │  │ │
│  │   │ • Incident response and business continuity           │  │ │
│  │   │ • Supplier security management                         │  │ │
│  │   │ • Internal audits and management reviews               │  │ │
│  │   │ • Continuous improvement process                       │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌─ SECURITY GOVERNANCE ──────────────────────────────────────────┐ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │              POLICY FRAMEWORK                           │  │ │
│  │   │                                                         │  │ │
│  │   │  Information Security Policy:                           │  │ │
│  │   │  ├─ Executive sponsorship and commitment                │  │ │
│  │   │  ├─ Scope and objectives definition                     │  │ │
│  │   │  ├─ Roles and responsibilities matrix                   │  │ │
│  │   │  ├─ Risk tolerance and appetite statements              │  │ │
│  │   │  └─ Annual review and update process                    │  │ │
│  │   │                                                         │  │ │
│  │   │  Data Classification Policy:                            │  │ │
│  │   │  ├─ Classification levels and criteria                  │  │ │
│  │   │  ├─ Handling and protection requirements               │  │ │
│  │   │  ├─ Labeling and marking standards                     │  │ │
│  │   │  ├─ Retention and disposal procedures                  │  │ │
│  │   │  └─ Access control and sharing guidelines               │  │ │
│  │   │                                                         │  │ │
│  │   │  Access Control Policy:                                 │  │ │
│  │   │  ├─ Identity and access management principles           │  │ │
│  │   │  ├─ Privileged access controls                         │  │ │
│  │   │  ├─ Regular access reviews and certifications          │  │ │
│  │   │  ├─ Segregation of duties requirements                 │  │ │
│  │   │  └─ Account lifecycle management                       │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                │ │
│  │   ┌─────────────────────────────────────────────────────────┐  │ │
│  │   │             RISK MANAGEMENT                             │  │ │
│  │   │                                                         │  │ │
│  │   │  Risk Assessment Process:                               │  │ │
│  │   │  ├─ Asset identification and valuation                 │  │ │
│  │   │  ├─ Threat and vulnerability analysis                  │  │ │
│  │   │  ├─ Impact and likelihood evaluation                   │  │ │
│  │   │  ├─ Risk scoring and prioritization                    │  │ │
│  │   │  └─ Treatment options and recommendations              │  │ │
│  │   │                                                         │  │ │
│  │   │  Risk Treatment Strategies:                             │  │ │
│  │   │  ├─ Accept: Low probability/impact risks               │  │ │
│  │   │  ├─ Mitigate: Implement controls to reduce risk        │  │ │
│  │   │  ├─ Transfer: Insurance or outsourcing                 │  │ │
│  │   │  ├─ Avoid: Eliminate the risk source                   │  │ │
│  │   │  └─ Monitor: Continuous assessment and review          │  │ │
│  │   │                                                         │  │ │
│  │   │  Key Risk Indicators (KRIs):                            │  │ │
│  │   │  ├─ Security incident frequency and severity           │  │ │
│  │   │  ├─ Vulnerability remediation time                     │  │ │
│  │   │  ├─ Compliance audit findings                          │  │ │
│  │   │  ├─ User access review completion rates                │  │ │
│  │   │  └─ Security training completion percentages           │  │ │
│  │   └─────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

**ARQUITETURA DE SEGURANCA ENTERPRISE COM DEFENSE IN DEPTH E ZERO TRUST**
