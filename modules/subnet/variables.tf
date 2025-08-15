// Variáveis do módulo Subnet
variable "subnet_name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "address_prefixes" { type = list(string) }
variable "service_endpoints" {
  type    = list(string)
  default = []
}
variable "delegation" {
  type    = any
  default = null
}
variable "nsg_name" { type = string }
variable "location" { type = string }
variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}
