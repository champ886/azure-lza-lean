#!/usr/bin/env bash
# Azure LZA — set auth context for local Terraform runs
azure-lza() {
  export ARM_USE_OIDC=false
  export ARM_USE_AZURE_CLI_AUTH=true
  export ARM_TENANT_ID="5a874bc4-9b37-4328-9c6f-b0df12fa23e0"
  export ARM_SUBSCRIPTION_ID="7fc27efc-58ce-41aa-b8ed-9ce148111f7b"
  echo "✅ Azure LZA auth set (platform sub)"
}

# Switch to a specific subscription (e.g. when testing workload layers)
azure-lza-dev() {
  azure-lza
  export ARM_SUBSCRIPTION_ID="6f5ab5c9-4f1c-43c2-b269-89441976bb0a"
  echo "✅ Azure LZA auth set (nonprod sub)"
}

azure-lza-prod() {
  azure-lza
  export ARM_SUBSCRIPTION_ID="830362ce-2781-45c9-865a-68b4e994deab"
  echo "✅ Azure LZA auth set (prod sub)"
}

# Clear Azure auth env vars
azure-unset() {
  unset ARM_USE_OIDC
  unset ARM_USE_AZURE_CLI_AUTH
  unset ARM_TENANT_ID
  unset ARM_SUBSCRIPTION_ID
  echo "✅ Azure ARM env vars cleared"
}