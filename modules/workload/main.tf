# =============================================================
# modules/workload/main.tf
# Spoke VNet — subnets, NSGs, private endpoints, Key Vault
# NO peering resources — AVNM owns peerings
# NO UDR resources — route table handles default route to hub
# =============================================================

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.platform]
    }
  }
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-workload-${var.environment}-${var.org_prefix}"
  location = var.location
  tags     = var.tags
}

# ── Spoke VNet ───────────────────────────────────────────────
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  address_space       = [var.spoke_address_space]
  tags                = var.tags
}

# ── Subnets ───────────────────────────────────────────────────
resource "azurerm_subnet" "workload" {
  name                 = "WorkloadSubnet"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.workload_subnet_cidr]

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ContainerRegistry",
  ]
}

resource "azurerm_subnet" "aks" {
  name                 = "AKSSubnet"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.aks_subnet_cidr]

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.ContainerRegistry",
  ]
}

resource "azurerm_subnet" "pe" {
  name                 = "PrivateEndpointSubnet"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.pe_subnet_cidr]
  private_endpoint_network_policies = "Disabled"
}

# ── Workload NSG ──────────────────────────────────────────────
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = var.tags

  # Allow Bastion SSH/RDP — source is VirtualNetwork covers all peered traffic
  security_rule {
    name                       = "allow-bastion-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Deny internet — priority 110 after bastion allow
  security_rule {
    name                       = "deny-direct-internet-inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow all VNet inbound
  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow LB health probes
  security_rule {
    name                       = "allow-lb-inbound"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}
# ── AKS NSG ───────────────────────────────────────────────────
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = var.tags

  # ── Deny direct internet inbound ─────────────────────────
  # AKS nodes should never be directly accessible from internet
  security_rule {
    name                       = "deny-direct-internet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # ── Allow AKS NodePort services ───────────────────────────
  # Required for Azure Load Balancer to reach AKS NodePort services
  security_rule {
    name                       = "allow-aks-nodeport"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # ── Allow VNet inbound ────────────────────────────────────
  # Allows inter-node communication and hub-to-spoke traffic
  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# ── NSG Associations ──────────────────────────────────────────
resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

# ── Route Table — default route to hub router VM ─────────────
# AVNM routing not yet supported in azurerm provider
# Route table pushes 0.0.0.0/0 → hub router VM as interim solution
# Phase 2: replace hub_router_vm_ip with ILB frontend IP when OPNsense deployed
resource "azurerm_route_table" "spoke" {
  name                = "rt-spoke-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = var.tags
}

resource "azurerm_route" "default_to_hub" {
  name                   = "default-to-hub-nva"
  resource_group_name    = azurerm_resource_group.workload.name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_router_vm_ip
}

resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = azurerm_subnet.workload.id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.spoke.id
}

# ── Key Vault — private endpoint, no public access ───────────
# RBAC authorization enabled — use role assignments not access policies
# Purge protection enabled in prod, disabled in dev for easier cleanup
resource "azurerm_key_vault" "spoke" {
  name                          = "kv-${var.environment}-${var.org_prefix}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.workload.name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = var.environment == "prod" ? true : false
  soft_delete_retention_days    = var.environment == "prod" ? 90 : 7
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [
      azurerm_subnet.workload.id,
      azurerm_subnet.aks.id,
    ]
  }
}

# ── Private Endpoint — Key Vault ─────────────────────────────
# All KV traffic stays on Azure backbone — no public internet
# DNS zone group links to shared privatelink.vaultcore zone in management layer
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-kv-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-kv-${var.environment}"
    private_connection_resource_id = azurerm_key_vault.spoke.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-group"
    private_dns_zone_ids = [var.dns_zone_vault_id]
  }
}

# ── Private Endpoint — ACR ────────────────────────────────────
# Optional — only deployed when acr_id is provided
resource "azurerm_private_endpoint" "acr" {
  count               = var.acr_id != "" ? 1 : 0
  name                = "pe-acr-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-acr-${var.environment}"
    private_connection_resource_id = var.acr_id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-group"
    private_dns_zone_ids = [var.dns_zone_acr_id]
  }
}

# ── Private Endpoint — Storage ────────────────────────────────
# Optional — only deployed when storage_account_id is provided
resource "azurerm_private_endpoint" "storage" {
  count               = var.storage_account_id != "" ? 1 : 0
  name                = "pe-sa-${var.environment}-${var.org_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  subnet_id           = azurerm_subnet.pe.id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-sa-${var.environment}"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sa-dns-group"
    private_dns_zone_ids = [var.dns_zone_blob_id]
  }
}

# ── Private DNS Zone VNet Links ───────────────────────────────
# Links shared privatelink DNS zones (in management layer) to this spoke VNet
# Enables private endpoint FQDN resolution from within the spoke
# Uses azurerm.platform provider alias — DNS zones live in platform sub
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-${var.environment}"
  resource_group_name   = var.management_rg_name
  private_dns_zone_name = var.dns_zone_blob_name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
  provider              = azurerm.platform
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault" {
  name                  = "link-vault-${var.environment}"
  resource_group_name   = var.management_rg_name
  private_dns_zone_name = var.dns_zone_vault_name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
  provider              = azurerm.platform
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "link-acr-${var.environment}"
  resource_group_name   = var.management_rg_name
  private_dns_zone_name = var.dns_zone_acr_name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
  provider              = azurerm.platform
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor" {
  name                  = "link-monitor-${var.environment}"
  resource_group_name   = var.management_rg_name
  private_dns_zone_name = var.dns_zone_monitor_name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
  provider              = azurerm.platform
}
