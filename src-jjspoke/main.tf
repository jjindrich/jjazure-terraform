terraform {
  backend "azurerm" {
    resource_group_name  = "jjdevmanagement"
    storage_account_name = "jjtfstate"
    container_name       = "jjspoke"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm    = "~> 2.1"
  }
}

# hub Azure subscription provider
provider "azurerm" {
  version = "~> 2.1"
  features {}
  subscription_id = var.subscriptionid_hub
  alias           = "hub"
}

# spoke Azure subscription provider
provider "azurerm" {
  version = "~> 2.1"
  features {}
  subscription_id = var.subscriptionid_spoke
}

# refer to existing resources
data "azurerm_virtual_network" "hubvnet" {
  name                = local.network_reference.network_name
  resource_group_name = local.network_reference.resource_group_name
  provider            = azurerm.hub
}

# create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = local.location  
}

# spoke network
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.location
  address_space       = var.network_address_space
  dns_servers         = var.network_dns
}

resource "azurerm_subnet" "vnet_sub1" {
  name                 = var.network_sub1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.network_sub1_address
}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                         = "${data.azurerm_virtual_network.hubvnet.name}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name          = data.azurerm_virtual_network.hubvnet.resource_group_name
  virtual_network_name         = data.azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  provider                     = azurerm.hub
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                         = "${azurerm_virtual_network.vnet.name}-to-${data.azurerm_virtual_network.hubvnet.name}"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hubvnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
