terraform {
  backend "azurerm" {
    resource_group_name  = "jjinfra-rg"
    storage_account_name = "jjaztfstate"
    container_name       = "jjazaks"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}

provider "azurerm" {
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
data "azurerm_log_analytics_workspace" "jjanalytics" {
  name                = local.monitoring.analytics_name
  resource_group_name = local.monitoring.resource_group_name
}
data "azurerm_resource_group" "rg-network" {
  name = local.network_reference.resource_group_name
}
data "azurerm_client_config" "current" {}

# create resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = local.location
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = local.location
  sku                 = "Basic"
  admin_enabled       = false
}

# create Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = var.app_insights_name
  location            = local.location
  resource_group_name = azurerm_resource_group.k8s.name
  application_type    = "web"
}

# create Application Configuration
resource "azurerm_app_configuration" "appconfig" {
  name                = var.app_config_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = local.location
}
# TODO add settings

# TODO create Sql server and database
# resource "azurerm_sql_server" "sqlserver" {
#   name                         = var.sql_server_name
#   resource_group_name          = azurerm_resource_group.k8s.name
#   location                     = local.location
#   version                      = "12.0"
#   administrator_login          = "jj"
#   administrator_login_password = "4-v3ry-53cr37-p455w0rd"
# }
# resource "azurerm_sql_database" "sqldb" {
#   name                = var.sql_db_name
#   resource_group_name = azurerm_resource_group.k8s.name
#   location            = local.location
#   server_name         = azurerm_sql_server.sqlserver.name
# }

# create Keyvault with secrets
resource "azurerm_key_vault" "kv" {
  name                       = var.kv_name
  resource_group_name        = azurerm_resource_group.k8s.name
  location                   = local.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}
# TODO access policy for github-app user managed identity
resource "azurerm_key_vault_secret" "kv_appInsightsConfig" {
  name         = "appInsightsConfig"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = azurerm_key_vault.kv.id
}
resource "azurerm_key_vault_secret" "kv_appInsightsKey" {
  name         = "appInsightsKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = azurerm_key_vault.kv.id
}
resource "azurerm_key_vault_secret" "kv_appConfig" {
  name         = "appConfig"
  value        = azurerm_app_configuration.appconfig.primary_read_key[0].connection_string
  key_vault_id = azurerm_key_vault.kv.id
}
# resource "azurerm_key_vault_secret" "kv_contactsDbConnection" {
#   name         = "contactsDbConnection"
#   value        = 
#   key_vault_id = azurerm_key_vault.kv.id
# }

