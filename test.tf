# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "jjterraformgroup" {
    name     = "JJTerraform"
    location = "westeurope"

    tags {
        environment = "JJ Terraform Demo"
    }
}

resource "azurerm_virtual_network" "jjterraformvnet"
{
    resource_group_name = "${azurerm_resource_group.jjterraformgroup.name}"
    name = "jjterraformvnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
}


