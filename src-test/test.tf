provider "azurerm" {
    features {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "jjterraformgroup" {
  name     = "JJTerraform"
  location = "westeurope"
}

resource "azurerm_virtual_network" "jjtfvnet" {
  resource_group_name = azurerm_resource_group.jjterraformgroup.name
  name                = "jjtfvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
}