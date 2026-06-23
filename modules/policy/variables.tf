variable "management_group_id" { type = string }
variable "location"            { type = string }
variable "policy_mode"         { 
                                 type = string
                                 default = "audit"
                               }   # "audit" | "enforce"
variable "deny_public_ips"     { 
                               type = bool
                               default = false
                               }
