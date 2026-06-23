# environments/shared/03-management/variables.tf
variable "org_prefix"               { type = string }
variable "org_name"                 { type = string }
variable "location"                 { type = string }
variable "platform_subscription_id" { type = string }
variable "security_email"           { type = string }
variable "law_retention_days"       { type = number }
variable "budget_amount"            { type = number }
variable "defender_tier"            { type = string }
variable "tfstate_rg_name"         { type = string }
variable "tfstate_sa_name"         { type = string }
variable "tfstate_container"       { type = string }
