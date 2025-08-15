variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "administrator_login" {
  type    = string
  default = "sqladminuser"
}

variable "sku_name" {
  type    = string
  default = "S0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
