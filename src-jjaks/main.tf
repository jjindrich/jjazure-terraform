provider "azurerm" {
  features {}
}

# refer to existing resources
data "azurerm_subnet" "akssubnet" {
  name                 = "DmzAks"
  virtual_network_name = "JJDevV2NetworkApp"
  resource_group_name  = "JJDevV2-Infra"
}
data "azurerm_key_vault" "jjkeyvault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}
data "azurerm_key_vault_secret" "spn_id" {
  name         = "tfClientApplicationId"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_key_vault_secret" "spn_secret" {
  name         = "tfClientSecret"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_log_analytics_workspace" "jjanalytics" {
  name                = "jjdev-analytics"
  resource_group_name = "jjdevmanagement"
}

# create resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = local.location
}