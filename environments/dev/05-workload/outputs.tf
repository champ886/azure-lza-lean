output "spoke_vnet_id" { value = module.workload.spoke_vnet_id }
output "key_vault_id"  { value = module.workload.key_vault_id }
output "workload_rg_name" {
  value = module.workload.workload_rg_name
}
output "workload_subnet_id" {
  value = module.workload.workload_subnet_id
}
