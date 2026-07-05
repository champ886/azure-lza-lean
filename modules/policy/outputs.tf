# modules/policy/outputs.tf
output "nsg_audit_assignment_id" {
  value = azurerm_management_group_policy_assignment.nsg_audit.id
}
