# environments/shared/03-management/terraform.tfvars
org_prefix               = "cc"
org_name                 = "Cloud Compass"
location                 = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
security_email           = "platform@algorhythm.au"
law_retention_days       = 90
budget_amount            = 500
defender_tier            = "Standard"
tfstate_rg_name         = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstatealg"
tfstate_container       = "tfstate"
