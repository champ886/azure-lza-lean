# environments/shared/05-avnm/terraform.tfvars
org_prefix               = "cc"
location                 = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
nonprod_subscription_id  = "6f5ab5c9-4f1c-43c2-b269-89441976bb0a"
prod_subscription_id     = "830362ce-2781-45c9-865a-68b4e994deab"
tfstate_rg_name         = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstate"
tfstate_container       = "tfstate"

# Phase 1: leave empty — uses router VM IP from hub state output
# Phase 2: set to ILB frontend IP (e.g. "10.2.1.5") to graduate to OPNsense
nva_next_hop_ip_override = ""
