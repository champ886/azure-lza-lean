terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform"
    storage_account_name = "cctfstatealg"
    container_name       = "tfstate"
    key                  = "alz/shared/04-hub/terraform.tfstate"
    use_oidc             = true
  }
}
