# environments/prod/05-workload/local.tfvars
# GITIGNORED — never commit this file
# Get storage account ID:
# az storage account show --name cctfstate --resource-group rg-tfstate-platform --query id -o tsv
flow_log_storage_account_id = "/subscriptions/7fc27efc-58ce-41aa-b8ed-9ce148111f7b/resourceGroups/rg-tfstate-platform/providers/Microsoft.Storage/storageAccounts/cctfstate"
