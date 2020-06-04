resource "azurerm_resource_group" "rgstorage" {
  name     = "storage-rg"
  location = local.location
}

resource "azurerm_storage_account" "st1" { 
  name = "jjst12345"
  location = local.location
  resource_group_name = azurerm_resource_group.rgstorage.name

  account_tier = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  access_tier = "Hot"

  enable_https_traffic_only = "true"
  
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    #ip_rules                   = []
    virtual_network_subnet_ids = [azurerm_subnet.vnet_sub1.id]
  }
}

resource "azurerm_storage_container" "container_address_autocomplete" {
  name                  = "addressautocomplete"
  storage_account_name  = azurerm_storage_account.st1.name
  container_access_type = "blob"
}
