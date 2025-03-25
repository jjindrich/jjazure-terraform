provider "azurerm" {
  features {}
  #subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

locals {
  location            = "germanywestcentral"
  resource_group_name = "rg-avm-jjvwan"
  tags = {
    environment = "avm-jjvwan-testing"
    deployment  = "terraform"
  }
  virtual_wan_name = "jjvwan"
  virtual_hub_key  = "jjvwan-gwc-vhub"
  virtual_hub_name = "${local.virtual_wan_name}-gwc-vhub"
}

module "vwan_with_vhub" {
  source  = "Azure/avm-ptn-virtualwan/azurerm"
  version = "0.9.0"
  resource_group_name            = local.resource_group_name
  create_resource_group          = true
  location                       = local.location
  virtual_wan_name               = local.virtual_wan_name
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  virtual_wan_tags               = local.tags
  virtual_hubs = {
    (local.virtual_hub_key) = {
      name           = local.virtual_hub_name
      location       = local.location
      resource_group = local.resource_group_name
      address_prefix = "10.0.0.0/24"
      tags           = local.tags
    }
  }
}