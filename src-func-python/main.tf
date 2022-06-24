terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# create resource group
resource "azurerm_resource_group" "rg" {
  name     = "jjfuncpython"
  location = local.location
}