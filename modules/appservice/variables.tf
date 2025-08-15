variable "container_image" {
  type    = string
  default = ""
}
variable "subnet_id" {
  type    = string
  default = null
}
variable "app_service_plan_name" { type = string }
variable "core_name" { type = string }
variable "history_name" { type = string }
variable "master_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku_tier" {
  type    = string
  default = "Standard"
}
variable "sku_size" {
  type    = string
  default = "S1"
}
variable "tags" {
  type    = map(string)
  default = {}
}
