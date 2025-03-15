data "azurerm_resource_group" "web" {
  name = var.web_resource_group_name
}

data "azurerm_client_config" "current" {}
