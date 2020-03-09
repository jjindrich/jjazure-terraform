module "caf_name_st" {
  source = "aztfmod/caf-naming/azurerm"

  name       = var.name
  type       = "st"
  convention = local.convention
}

module "rg_test" {
  source  = "aztfmod/caf-resource-group/azurerm"
  
    prefix          = local.prefix
    resource_groups = local.resource_groups
}

resource "azurerm_storage_account" "log" {
  name                      = module.caf_name_st.st
  resource_group_name       = module.rg_test.names.test
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}
