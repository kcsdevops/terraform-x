variable "tags" {
  type    = map(string)
  default = {}
}
variable "storage_account_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "account_tier" {
  type    = string
  default = "Standard"
}
variable "account_replication_type" {
  type    = string
  default = "LRS"
}
variable "blob_container_name" {
  type    = string
  default = "staticfiles"
}
variable "container_access_type" {
  type    = string
  default = "private"
}
variable "queue_name" {
  type    = string
  default = "mainqueue"
}
