data "azurerm_resource_group" "web" {
  name     = "${var.web_resource_group_name}"
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-dev-calicot-cc-${var.suffix}"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.web.location
  resource_group_name = data.azurerm_resource_group.web.name
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = data.azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = data.azurerm_resource_group.web.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "plan-calicot-dev-${var.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.web.name
  os_type             = "Linux"
  sku_name = "S1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "app-calicot-dev-${var.suffix}"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.web.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  depends_on            = [azurerm_service_plan.appserviceplan]
  https_only            = true
  site_config { 
    always_on = true
  }
  app_settings = {
    "ImageUrl" = "https://stcalicotprod000.blob.core.windows.net/images/"
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.webapp.id
  repo_url           = "https://github.com/RomainL972/CalicotEncheres"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}
