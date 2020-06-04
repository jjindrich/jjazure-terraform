resource "azurerm_resource_group" "rgsql" {
  name     = "sql-rg"
  location = local.location
}

resource "azurerm_postgresql_server" "sql" {
  name                = "jjsql12345"
  location            = azurerm_resource_group.rgsql.location
  resource_group_name = azurerm_resource_group.rgsql.name

  sku_name = "B_Gen5_2"
  #sku_name = "GP_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "db1" {
  name                = "jjdb1"
  resource_group_name = azurerm_resource_group.rgsql.name
  server_name         = azurerm_postgresql_server.sql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}