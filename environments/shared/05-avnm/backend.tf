terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform"
    storage_account_name = "cctfstate"
    container_name       = "tfstate"
    key                  = "alz/shared/05-avnm/terraform.tfstate"
    use_oidc             = true
  }
}
