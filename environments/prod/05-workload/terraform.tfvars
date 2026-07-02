# environments/prod/05-workload/terraform.tfvars
org_prefix               = "cc"
environment              = "prod"
location                 = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
workload_subscription_id = "830362ce-2781-45c9-865a-68b4e994deab"
spoke_address_space      = "10.20.0.0/16"
workload_subnet_cidr     = "10.20.1.0/24"
aks_subnet_cidr          = "10.20.2.0/22"
pe_subnet_cidr           = "10.20.10.0/24"
acr_id                   = ""   # set when ACR is created
tfstate_rg_name         = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstatealg"
tfstate_container       = "tfstate"
# flow_log_storage_account_id — set in local.tfvars (gitignored)
