# environments/dev/01-management-groups/main.tf
module "management_groups" {
  source = "../../../modules/management-groups"

  org_prefix               = var.org_prefix
  org_name                 = var.org_name
  platform_subscription_id = var.platform_subscription_id
  nonprod_subscription_id  = var.nonprod_subscription_id
  prod_subscription_id     = var.prod_subscription_id
  tags = { ManagedBy = "Terraform", Layer = "01-management-groups" }
}

