terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform"
    storage_account_name = "cctfstate"
    container_name       = "tfstate"
    key                  = "alz/prod/02-policy/terraform.tfstate"
    use_oidc             = true
  }
}
