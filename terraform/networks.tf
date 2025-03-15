resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.deployment_type}-calicot-cc-${var.suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.web.location
  resource_group_name = data.azurerm_resource_group.web.name
}

resource "azurerm_subnet" "web" {
  name                 = "subnet-calicot-web-${var.deployment_type}-${var.suffix}"
  resource_group_name  = data.azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "subnet-calicot-db-${var.deployment_type}-${var.suffix}"
  resource_group_name  = data.azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}
