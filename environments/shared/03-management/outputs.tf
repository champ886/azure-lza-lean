output "law_workspace_id" {
  value = module.management.law_workspace_id
}
output "law_workspace_key" {
  value     = module.management.law_workspace_key
  sensitive = true
}
output "management_rg_name" {
  value = module.management.management_rg_name
}
output "management_rg_id" {
  value = module.management.management_rg_id
}
output "dns_zone_blob_id" {
  value = module.management.dns_zone_blob_id
}
output "dns_zone_vault_id" {
  value = module.management.dns_zone_vault_id
}
output "dns_zone_acr_id" {
  value = module.management.dns_zone_acr_id
}
output "dns_zone_aks_id" {
  value = module.management.dns_zone_aks_id
}
output "dns_zone_monitor_id" {
  value = module.management.dns_zone_monitor_id
}
output "dns_zone_blob_name" {
  value = module.management.dns_zone_blob_name
}
output "dns_zone_vault_name" {
  value = module.management.dns_zone_vault_name
}
output "dns_zone_acr_name" {
  value = module.management.dns_zone_acr_name
}
output "dns_zone_monitor_name" {
  value = module.management.dns_zone_monitor_name
}
output "law_workspace_guid" {
  value = module.management.law_workspace_guid
}