resource "azurerm_resource_group" "rg-vmappwin" {
  name     = "${local.vmappwin.name}-rg"
  location = local.location
}

resource "azurerm_network_interface" "vmappwin-nic" {
  name                = "${local.vmappwin.name}-nic"
  location            = azurerm_resource_group.rg-vmappwin.location
  resource_group_name = azurerm_resource_group.rg-vmappwin.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vnet_sub1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vmappwin" {
  name                  = local.vmappwin.name
  location              = azurerm_resource_group.rg-vmappwin.location
  resource_group_name   = azurerm_resource_group.rg-vmappwin.name
  network_interface_ids = [azurerm_network_interface.vmappwin-nic.id]
  size                  = "Standard_B2ms"

  admin_username = "jj"
  admin_password = data.azurerm_key_vault_secret.password.value

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers"
    version   = "latest"
  }
  os_disk {
    name                 = "${local.vmappwin.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}

# join Windows domain
resource "azurerm_virtual_machine_extension" "vmappwin-ext" {
  name                 = "vmappwin"
  virtual_machine_id   = azurerm_windows_virtual_machine.vmappwin.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings           = <<SETTINGS
    {
        "Name": "jjdev.local",
        "OUPath": "OU=JJDevOrg,DC=jjdev,DC=local",
        "User": "JJDEV\\jj",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${data.azurerm_key_vault_secret.ad-password.value}"
    }
  PROTECTED_SETTINGS
  depends_on         = [azurerm_windows_virtual_machine.vmappwin]
}

# run script - install application
# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows#running-scripts-from-a-local-share
resource "azurerm_virtual_machine_extension" "script-ext" {
  name                 = "script-install-win"
  virtual_machine_id   = azurerm_windows_virtual_machine.vmappwin.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Bypass -File \\\\jjdevv2addc.jjdev.local\\share\\install-win.ps1"
    }
SETTINGS
}