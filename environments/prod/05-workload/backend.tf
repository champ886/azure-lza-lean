terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-platform"
    storage_account_name = "cctfstate"
    container_name       = "tfstate"
    key                  = "alz/prod/05-workload/terraform.tfstate"
    use_oidc             = true
  }
}
