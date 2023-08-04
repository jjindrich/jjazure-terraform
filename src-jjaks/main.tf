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
data "azurerm_key_vault" "jjkeyvault" {
  name                = local.keyvault_reference.keyvault_name
  resource_group_name = local.keyvault_reference.resource_group_name
}
data "azurerm_key_vault_secret" "sql_password" {
  name         = "SqlPassword"
  key_vault_id = data.azurerm_key_vault.jjkeyvault.id
}
data "azurerm_user_assigned_identity" "identity_appdeploy" {
  name                = local.appdeploy_identity_reference.identity_name
  resource_group_name = local.appdeploy_identity_reference.resource_group_name
}
data "azurerm_client_config" "current" {}

# create resource group
resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = local.location
}
resource "azurerm_role_assignment" "k8s_contributor" {
  scope                = azurerm_resource_group.k8s.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.identity_appdeploy.principal_id
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
  workspace_id        = data.azurerm_log_analytics_workspace.jjanalytics.id
  application_type    = "web"
}

# create Application Configuration
resource "azurerm_app_configuration" "appconfig" {
  name                = var.app_config_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = local.location
}
resource "azurerm_role_assignment" "appconfig_owner" {
  scope                = azurerm_app_configuration.appconfig.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_app_configuration_feature" "appconfig_allowtest" {
  configuration_store_id = azurerm_app_configuration.appconfig.id
  name                   = "AllowTests"
  description            = "Enable Test menu"
  enabled                = true
  depends_on = [
    azurerm_role_assignment.appconfig_owner
  ]
}
resource "azurerm_app_configuration_feature" "appconfig_allowabout" {
  configuration_store_id = azurerm_app_configuration.appconfig.id
  name                   = "AllowAbout"
  description            = "Enable About menu"
  enabled                = true
  depends_on = [
    azurerm_role_assignment.appconfig_owner
  ]
}

# create Sql server and database
resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.k8s.name
  location                     = local.location
  version                      = "12.0"
  administrator_login          = "jj"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value
  # TODO: private endpoint configuration missing
  public_network_access_enabled = false
}
resource "azurerm_mssql_firewall_rule" "sqlserver_fw" {
  name             = "AllAzureServices"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
resource "azurerm_mssql_database" "sqldb" {
  name                        = var.sql_db_name
  server_id                   = azurerm_mssql_server.sqlserver.id
  sku_name                    = "GP_S_Gen5_1"
  auto_pause_delay_in_minutes = 60
  max_size_gb                 = 32
  min_capacity                = 0.5
}

# create Keyvault with secrets
resource "azurerm_key_vault" "kv" {
  name                            = var.kv_name
  resource_group_name             = azurerm_resource_group.k8s.name
  location                        = local.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
  enabled_for_template_deployment = true
}
resource "azurerm_key_vault_access_policy" "kv_access_current" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "List",
    "Recover",
    "Backup",
    "Restore"
  ]
}
resource "azurerm_key_vault_access_policy" "kv_access_app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_user_assigned_identity.identity_appdeploy.principal_id
  secret_permissions = [
    "Set",
    "Get",
    "Delete",
    "Purge",
    "List",
    "Recover",
    "Backup",
    "Restore"
  ]
}
resource "azurerm_key_vault_secret" "kv_appInsightsConfig" {
  name         = "appInsightsConfig"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.kv_access_current
  ]
}
resource "azurerm_key_vault_secret" "kv_appInsightsKey" {
  name         = "appInsightsKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.kv_access_current
  ]
}
resource "azurerm_key_vault_secret" "kv_appConfig" {
  name         = "appConfig"
  value        = azurerm_app_configuration.appconfig.primary_read_key[0].connection_string
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.kv_access_current
  ]
}
resource "azurerm_key_vault_secret" "kv_contactsDbConnection" {
  name         = "contactsDbConnection"
  value        = "Server=tcp:${azurerm_mssql_server.sqlserver.name}.database.windows.net\\,1433;Initial Catalog=${azurerm_mssql_database.sqldb.name};Persist Security Info=False;User ID=jj;Password=${data.azurerm_key_vault_secret.sql_password.value};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [
    azurerm_key_vault_access_policy.kv_access_current
  ]
}

# Create Grafana and Prometheus workspace
resource "azurerm_monitor_workspace" "jjprometheus" {
  name                = var.prometheus_name
  resource_group_name = azurerm_resource_group.k8s.name
  location            = local.location
}

resource "azurerm_dashboard_grafana" "jjgrafana" {
  name                              = var.grafana_name
  resource_group_name               = azurerm_resource_group.k8s.name
  location                          = local.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.jjprometheus.id
  }

  identity {
    type = "SystemAssigned"
  }
}
