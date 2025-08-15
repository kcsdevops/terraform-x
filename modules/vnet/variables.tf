// Variáveis do módulo VNet
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "dns_servers" {
  type    = list(string)
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}
