# environments/shared/04-hub/terraform.tfvars
org_prefix              = "cc"
location                = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
hub_address_space       = "10.2.0.0/16"
nva_subnet_cidr         = "10.2.1.0/24"
gateway_subnet_cidr     = "10.2.0.64/27"
bastion_subnet_cidr     = "10.2.0.128/26"
management_subnet_cidr  = "10.2.2.0/24"
nat_gw_subnet_cidr      = "10.2.3.0/24"
router_vm_ip            = "10.2.1.4"
tfstate_rg_name        = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstatealg"
tfstate_container      = "tfstate"
# environments/shared/04-hub/terraform.tfvars
router_vm_size = "Standard_D2s_v3"
# router_ssh_public_key — set in local.tfvars (gitignored) or GitHub Secret
# router_ssh_public_key = "ssh-ed25519 AAAA..."
# Bastion — toggle on for VM access, off when done to save cost
deploy_bastion = false

