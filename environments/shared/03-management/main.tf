# environments/shared/03-management/main.tf
data "azurerm_client_config" "current" {}

data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_rg_name
    storage_account_name = var.tfstate_sa_name
    container_name       = var.tfstate_container
    key                  = "alz/shared/04-hub/terraform.tfstate"
  }
}

module "management" {
  source = "../../../modules/management"

  org_prefix               = var.org_prefix
  location                 = var.location
  law_retention_days       = var.law_retention_days
  budget_amount            = var.budget_amount
  defender_tier            = var.defender_tier
  security_email           = var.security_email
  platform_subscription_id = var.platform_subscription_id
  management_subnet_id     = data.terraform_remote_state.hub.outputs.management_subnet_id

  tags = {
    Environment = "shared"
    ManagedBy   = "Terraform"
    Layer       = "03-management"
    OrgPrefix   = var.org_prefix
  }
}
