terraform {
  backend "azurerm" {
    resource_group_name  = "jjdevmanagement"
    storage_account_name = "jjtfstate"
    container_name       = "jjaks"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm    = "~> 2.24"
    helm       = "~> 2.0"
    kubernetes = "~> 1.12"
  }
}

provider "azurerm" {
  version = "~> 2.24"
  features {}
}

# required permissions to run TF scripts (creates Azure resources and configuring access for System Manageged Identity)
# Contributor and User Access Administrator

# refer to existing resources
data "azurerm_subnet" "akssubnet" {
  name                 = local.network_reference.subnet_name
  virtual_network_name = local.network_reference.network_name
  resource_group_name  = local.network_reference.resource_group_name
}
data "azurerm_key_vault" "jjkeyvault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}
/*
data "azurerm_key_vault_secret" "spn_id" {
  name         = "aksserverApplicationId"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_key_vault_secret" "spn_secret" {
  name         = "aksserverApplicationSecret"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_key_vault_secret" "client_id" {
  name         = "aksclientApplicationId"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
*/
data "azurerm_key_vault_secret" "node_windows_password" {
  name         = "akswinpassword"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_log_analytics_workspace" "jjanalytics" {
  name                = local.monitoring.analytics_name
  resource_group_name = local.monitoring.resource_group_name
}
data "azurerm_resource_group" "rg-network" {
  name = local.network_reference.resource_group_name
}
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_rg
}

# create resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = local.location
}
