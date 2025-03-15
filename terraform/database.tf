resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sqlsrv-calicot-${var.deployment_type}-${var.suffix}"
  resource_group_name          = data.azurerm_resource_group.web.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "sqldb-calicot-${var.deployment_type}-${var.suffix}"
  server_id = azurerm_mssql_server.sqlserver.id
}

resource "azurerm_mssql_virtual_network_rule" "sqldb_network" {
  name = "vnet-rule-${var.deployment_type}-${var.suffix}"
  server_id                 = azurerm_mssql_server.sqlserver.id
  subnet_id                 = azurerm_subnet.db.id
}
