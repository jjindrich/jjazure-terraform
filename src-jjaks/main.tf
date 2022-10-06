terraform {
  backend "azurerm" {
    resource_group_name  = "jjinfra-rg"
    storage_account_name = "jjaztfstate"
    container_name       = "jjazaks"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc        = true
}

# required permissions to run TF scripts (creates Azure resources and configuring access for System Manageged Identity)
# Contributor and User Access Administrator

# refer to existing resources
data "azurerm_subnet" "akssubnet" {
  name                 = local.network_reference.subnet_name
  virtual_network_name = local.network_reference.network_name
  resource_group_name  = local.network_reference.resource_group_name
}
data "azurerm_log_analytics_workspace" "jjanalytics" {
  name                = local.monitoring.analytics_name
  resource_group_name = local.monitoring.resource_group_name
}
data "azurerm_resource_group" "rg-network" {
  name = local.network_reference.resource_group_name
}

# create resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = local.location
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = local.location
  sku                 = "Basic"
  admin_enabled       = false
}