terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform"
    storage_account_name = "cctfstate"
    container_name       = "tfstate"
    key                  = "alz/prod/01-management-groups/terraform.tfstate"
    use_oidc             = true
  }
}
