# Compliance Monitoring Module
# Monitoramento de conformidade e governança

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização dos recursos"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  type        = string
}

variable "subscription_id" {
  description = "ID da Subscription Azure"
  type        = string
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
}

# Data source para subscription
data "azurerm_client_config" "current" {}

# Policy Definition para LGPD Compliance
resource "azurerm_policy_definition" "lgpd_compliance" {
  name         = "lgpd-data-protection"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "LGPD Data Protection Compliance"
  description  = "Ensure resources comply with LGPD data protection requirements"

  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "in": [
          "Microsoft.Storage/storageAccounts",
          "Microsoft.Sql/servers/databases",
          "Microsoft.DocumentDB/databaseAccounts"
        ]
      },
      {
        "anyOf": [
          {
            "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
            "equals": false
          },
          {
            "field": "Microsoft.Sql/servers/databases/transparentDataEncryption.status",
            "notEquals": "Enabled"
          }
        ]
      }
    ]
  },
  "then": {
    "effect": "audit"
  }
}
POLICY_RULE

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "type": "Array",
    "metadata": {
      "description": "The list of allowed locations for resources",
      "displayName": "Allowed locations"
    },
    "defaultValue": ["Brazil South", "Brazil Southeast"]
  }
}
PARAMETERS
}

# Policy Assignment para LGPD
resource "azurerm_resource_group_policy_assignment" "lgpd_compliance" {
  name                 = "lgpd-compliance-assignment"
  resource_group_id    = "/subscriptions/\/resourceGroups/\"
  policy_definition_id = azurerm_policy_definition.lgpd_compliance.id
  description          = "Assignment of LGPD compliance policy"
  display_name         = "LGPD Compliance Assignment"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": ["Brazil South", "Brazil Southeast"]
  }
}
PARAMETERS
}

# Saved Search para Compliance Monitoring
resource "azurerm_log_analytics_saved_search" "compliance_violations" {
  name                       = "ComplianceViolations"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  category                   = "Compliance"
  display_name              = "LGPD Compliance Violations"
  query                     = <<-EOQ
AzureActivity
| where OperationNameValue contains "PolicyViolation"
| extend PolicyName = tostring(parse_json(Properties).policies[0].policyDefinitionName)
| where PolicyName contains "lgpd"
| summarize ViolationCount = count() by ResourceGroup, PolicyName, bin(TimeGenerated, 1d)
| order by TimeGenerated desc
EOQ
}

resource "azurerm_log_analytics_saved_search" "data_access_audit" {
  name                       = "DataAccessAudit"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  category                   = "Compliance"
  display_name              = "Data Access Audit Trail"
  query                     = <<-EOQ
AuditLogs
| where Category in ("DataAccess", "DataWrite", "DataRead")
| extend UserInfo = case(
    isnotempty(InitiatedBy.user.userPrincipalName), InitiatedBy.user.userPrincipalName,
    isnotempty(InitiatedBy.app.displayName), InitiatedBy.app.displayName,
    "Unknown"
)
| project TimeGenerated, UserInfo, Category, OperationName, Result, ResourceId
| order by TimeGenerated desc
EOQ
}

resource "azurerm_log_analytics_saved_search" "encryption_status" {
  name                       = "EncryptionStatus"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  category                   = "Security"
  display_name              = "Encryption Status Monitor"
  query                     = <<-EOQ
AzureMetrics
| where ResourceProvider == "MICROSOFT.STORAGE" or ResourceProvider == "MICROSOFT.SQL"
| where MetricName in ("EncryptionEnabled", "TransparentDataEncryption")
| summarize EncryptionStatus = avg(Average) by Resource, bin(TimeGenerated, 1h)
| where EncryptionStatus < 1
| order by TimeGenerated desc
EOQ
}

# Security Center Regulatory Compliance
resource "azurerm_security_center_subscription_pricing" "standard" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

# Key Vault para armazenar chaves de compliance
resource "azurerm_key_vault" "compliance" {
  name                = "\-compliance-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]

    certificate_permissions = [
      "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
    ]
  }

  tags = merge(var.tags, {
    Purpose = "Compliance"
    LGPD    = "Required"
  })
}

# Secret para audit trail
resource "azurerm_key_vault_secret" "audit_trail_key" {
  name         = "audit-trail-encryption-key"
  value        = "compliance-audit-key-\"
  key_vault_id = azurerm_key_vault.compliance.id

  tags = {
    Purpose = "Audit Trail Encryption"
    LGPD    = "Required"
  }
}

resource "random_id" "audit_key" {
  byte_length = 32
}

# Outputs
output "compliance_key_vault_id" {
  description = "ID do Key Vault de compliance"
  value       = azurerm_key_vault.compliance.id
}

output "policy_definition_id" {
  description = "ID da definição de política LGPD"
  value       = azurerm_policy_definition.lgpd_compliance.id
}

output "policy_assignment_id" {
  description = "ID da atribuição de política LGPD"
  value       = azurerm_resource_group_policy_assignment.lgpd_compliance.id
}

output "compliance_queries" {
  description = "IDs das queries de compliance salvas"
  value = {
    violations     = azurerm_log_analytics_saved_search.compliance_violations.id
    data_access    = azurerm_log_analytics_saved_search.data_access_audit.id
    encryption     = azurerm_log_analytics_saved_search.encryption_status.id
  }
}
