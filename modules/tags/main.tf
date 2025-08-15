// Módulo para gerar tags padrão para recursos
locals {
  tags = {
    environment = var.environment
    project     = "MEURH360"
    owner       = var.owner
    resource    = var.resource_name
    rg_pattern  = "RG-MEURH360-${var.resource_name}-${upper(var.environment)}"
  }
}

output "tags" {
  value = local.tags
}
