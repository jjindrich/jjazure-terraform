// Azure Functions
resource "azurerm_storage_account" "st" {
  name                     = "jjfuncpythonst"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = "jjfuncpythonplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  
  // use App Service Plan
  //sku_name            = "P1v3"
  
  // use App Service Environment
  sku_name            = "I1v2"
  app_service_environment_id = azurerm_app_service_environment_v3.ase.id
}

resource "azurerm_linux_function_app" "func" {
  name                = "jjfuncpython"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.st.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key
  service_plan_id            = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      docker {
        registry_url      = var.acr_name
        image_name        = "func-python"
        image_tag         = "v1.0.0"
        registry_username = var.acr_username
        registry_password = var.acr_password
      }
    }
  }
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "DOCKER_ENABLE_CI"       = true
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    // uncomment to corrupt the function app running on App Service Environment
    // removes "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" and "WEBSITE_CONTENTSHARE" when running update
    //"JJTEST" = "jjtest" 
  }
  // workaround to fix it -> use always: content_share_force_disabled = true
  //content_share_force_disabled = true

  builtin_logging_enabled = true
}
