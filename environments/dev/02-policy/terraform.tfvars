# environments/dev/02-policy/terraform.tfvars
location                = "australiaeast"
platform_subscription_id = "7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
policy_mode             = "audit"
deny_public_ips         = false
tfstate_rg_name        = "rg-tfstate-platform"
tfstate_sa_name         = "cctfstatealg"
tfstate_container      = "tfstate"

