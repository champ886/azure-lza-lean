variable "location" {
  type    = string
  default = "australiaeast"
}
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
variable "ssh_public_key" {
  type      = string
  sensitive = true
}
variable "workload_subscription_id" {
  type    = string
  default = "6f5ab5c9-4f1c-43c2-b269-89441976bb0a"
}
