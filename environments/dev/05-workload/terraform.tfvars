# environments/dev/05-workload/terraform.tfvars
org_prefix               = "cc"
environment              = "dev"
location                 = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
workload_subscription_id = "6f5ab5c9-4f1c-43c2-b269-89441976bb0a"
spoke_address_space      = "10.10.0.0/16"
workload_subnet_cidr     = "10.10.1.0/24"
aks_subnet_cidr          = "10.10.4.0/22"
pe_subnet_cidr           = "10.10.10.0/24"
acr_id                   = ""   # set when ACR is created
tfstate_rg_name         = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstatealg"
tfstate_container       = "tfstate"
# flow_log_storage_account_id — set in local.auto.tfvars (gitignored)
# Get with: az storage account show --name cctfstate --resource-group rg-tfstate-platform --query id -o tsv
