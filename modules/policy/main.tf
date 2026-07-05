# modules/policy/main.tf

# ── Built-in: Subnets should have NSG ────────────────────────
# Audit only — flags subnets without NSG
resource "azurerm_management_group_policy_assignment" "nsg_audit" {
  name                 = "audit-nsg-subnets"
  display_name         = "Subnets should be associated with a Network Security Group"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    effect = { value = "AuditIfNotExists" }
  })
}

# ── Built-in: Deny RDP from internet (deprecated — Audit only) 
resource "azurerm_management_group_policy_assignment" "deny_rdp" {
  name                 = "audit-rdp-internet"
  display_name         = "RDP access from the Internet should be blocked"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e372f825-a257-4fb8-9175-797a8a8627d6"
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    effect = { value = "Audit" }
  })
}

# ── Built-in: Deny SSH from internet (deprecated — Audit only)
resource "azurerm_management_group_policy_assignment" "deny_ssh" {
  name                 = "audit-ssh-internet"
  display_name         = "SSH access from the Internet should be blocked"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2c89a2e5-7285-40fe-afe0-ae8654b92fab"
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    effect = { value = "Audit" }
  })
}

# ── Built-in: Deny public IP on NICs (prod only) ─────────────
resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  count                = var.deny_public_ips ? 1 : 0
  name                 = "deny-public-ip-nic"
  display_name         = "Deny public IP on VM NICs"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-ddc1adde0c2d"
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    effect = { value = "Deny" }
  })
}