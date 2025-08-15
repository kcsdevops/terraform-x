# Keycloak Container App Module

This Terraform module deploys Keycloak identity and access management system on Azure Container Apps with full integration to Azure Key Vault for secrets management.

## Architecture

The module creates:

- **Azure Container Apps Environment** - Managed Kubernetes platform for running Keycloak
- **PostgreSQL Flexible Server** - Database backend for Keycloak
- **Azure Key Vault** - Secure storage for all secrets and keys
- **Virtual Network** - Network isolation and security
- **User-Assigned Managed Identity** - Secure authentication between services
- **Log Analytics Workspace** - Monitoring and logging

## Features

- **High Availability**: Auto-scaling Container Apps with health probes
- **Security**: All secrets stored in Key Vault with managed identity access
- **Network Isolation**: Private network with delegated subnets
- **Monitoring**: Integrated logging and metrics collection
- **Production Ready**: Optimized Keycloak configuration with database persistence

## Usage

```hcl
module "keycloak" {
  source = "./modules/keycloak-container-app"

  # General Configuration
  keycloak_name       = "my-keycloak"
  location            = "Brazil South"
  resource_group_name = "keycloak-rg"

  # Key Vault Configuration
  key_vault_name = "my-keycloak-kv"

  # Network Configuration
  vnet_address_space          = "10.100.0.0/16"
  container_apps_subnet_cidr  = "10.100.1.0/24"
  database_subnet_cidr        = "10.100.2.0/24"

  # Keycloak Configuration
  keycloak_hostname = "keycloak.mydomain.com"

  # System Integration Secrets
  system_secrets = {
    "api-client-secret"     = "your-api-client-secret"
    "ldap-bind-password"    = "your-ldap-password"
    "smtp-password"         = "your-smtp-password"
    "external-db-password"  = "your-external-db-password"
  }

  tags = {
    project     = "identity-management"
    environment = "production"
    owner       = "platform-team"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `keycloak_url` | URL to access Keycloak |
| `keycloak_admin_url` | URL to access Keycloak admin console |
| `key_vault_id` | ID of the Key Vault |
| `key_vault_uri` | URI of the Key Vault |
| `managed_identity_id` | ID of the managed identity |
| `postgres_server_fqdn` | FQDN of the PostgreSQL server |
| `container_app_fqdn` | FQDN of the Container App |

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `resource_group_name` | Name of the resource group | `string` |
| `key_vault_name` | Name of the Azure Key Vault | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `keycloak_name` | Name prefix for Keycloak resources | `string` | `"keycloak"` |
| `location` | Azure region for all resources | `string` | `"Brazil South"` |
| `keycloak_image` | Keycloak container image | `string` | `"quay.io/keycloak/keycloak:latest"` |
| `container_cpu` | CPU allocation for container | `number` | `1.0` |
| `container_memory` | Memory allocation for container | `string` | `"2Gi"` |
| `min_replicas` | Minimum number of replicas | `number` | `1` |
| `max_replicas` | Maximum number of replicas | `number` | `3` |

## Key Vault Integration

The module automatically stores the following secrets in Key Vault:

- `keycloak-admin-password` - Keycloak administrator password
- `keycloak-db-password` - PostgreSQL database password
- Any additional secrets provided via `system_secrets` variable

## Security Features

1. **Network Security**:
   - Private virtual network with delegated subnets
   - Network Security Groups with restrictive rules
   - Private DNS zones for database connectivity

2. **Identity and Access**:
   - User-assigned managed identity for secure service communication
   - Key Vault access policies with least privilege
   - No hardcoded credentials in configuration

3. **Data Protection**:
   - All secrets stored in Key Vault
   - Database encryption at rest and in transit
   - Container-to-database communication over private network

## Monitoring and Logging

- Log Analytics workspace for centralized logging
- Container Apps environment metrics
- Health probes for application monitoring
- PostgreSQL server metrics and diagnostics

## Cost Optimization

- Uses Basic tier PostgreSQL for development environments
- Container Apps with auto-scaling (min 1, max 3 replicas)
- Standard tier Key Vault (can be upgraded to Premium if needed)
- Local redundant storage for cost efficiency

## Prerequisites

1. Azure subscription with appropriate permissions
2. Terraform >= 1.0
3. Azure CLI or Service Principal authentication
4. Resource group created (if not using existing)

## Post-Deployment Steps

1. Access Keycloak admin console at the provided URL
2. Log in with admin credentials from Key Vault
3. Configure realms, clients, and users as needed
4. Set up custom domain and SSL certificate (optional)
5. Configure SMTP settings for email notifications

## Integration Examples

### API Client Registration

```bash
# Get admin password from Key Vault
ADMIN_PASSWORD=$(az keyvault secret show --name keycloak-admin-password --vault-name <key-vault-name> --query value -o tsv)

# Access Keycloak admin API to create clients
curl -X POST "https://<keycloak-fqdn>/admin/realms/master/clients" \
  -H "Authorization: Bearer <access-token>" \
  -H "Content-Type: application/json" \
  -d '{"clientId": "my-api", "enabled": true}'
```

### Application Integration

```yaml
# Example Spring Boot application.yml
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: my-api
            client-secret: ${KEYCLOAK_CLIENT_SECRET}
            authorization-grant-type: authorization_code
        provider:
          keycloak:
            issuer-uri: https://<keycloak-fqdn>/realms/myrealm
```

## Troubleshooting

### Common Issues

1. **Container App not starting**:
   - Check Container Apps logs: `az containerapp logs show`
   - Verify database connectivity and credentials

2. **Database connection issues**:
   - Ensure PostgreSQL server allows connections from Container Apps subnet
   - Verify private DNS zone configuration

3. **Key Vault access denied**:
   - Check managed identity permissions
   - Verify Key Vault access policies

### Useful Commands

```bash
# Check Container App status
az containerapp show --name <keycloak-name> --resource-group <rg-name>

# View application logs
az containerapp logs show --name <keycloak-name> --resource-group <rg-name>

# Get Key Vault secrets
az keyvault secret list --vault-name <key-vault-name>

# Test database connectivity
az postgres flexible-server connect --name <postgres-name> --resource-group <rg-name>
```
