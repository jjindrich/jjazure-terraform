resource "azurerm_resource_group" "rg-vmapplx" {
  name     = "${local.vmapplx.name}-rg"
  location = local.location
}

resource "azurerm_network_interface" "vmapplx-nic" {
  name                = "${local.vmapplx.name}-nic"
  location            = azurerm_resource_group.rg-vmapplx.location
  resource_group_name = azurerm_resource_group.rg-vmapplx.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vnet_sub1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vmapplx" {
  name                  = local.vmapplx.name
  location              = azurerm_resource_group.rg-vmapplx.location
  resource_group_name   = azurerm_resource_group.rg-vmapplx.name
  network_interface_ids = [azurerm_network_interface.vmapplx-nic.id]
  size                  = "Standard_B1s"

  admin_username                  = "jj"
  disable_password_authentication = false
  admin_password                  = data.azurerm_key_vault_secret.password.value

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "${local.vmapplx.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}

# run script - install application
resource "azurerm_virtual_machine_extension" "script-lx-ext" {
  name                 = "script-install-lx"
  virtual_machine_id   = azurerm_linux_virtual_machine.vmapplx.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute" : "apt-get -y update && apt-get install -y apache2" 
    }
    SETTINGS
}
