// App Service Environment v3
resource "azurerm_virtual_network" "vnet" {
  name                = "jjfuncpythonvnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "ase_sn" {
  name                 = "ase"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"
    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_app_service_environment_v3" "ase" {
  name                = "jjfuncpythonase"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.ase_sn.id

  internal_load_balancing_mode = "None"
}