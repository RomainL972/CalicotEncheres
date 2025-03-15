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

    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "ImageUrl" = "https://stcalicotprod000.blob.core.windows.net/images/"
  }

  identity {
    type = "SystemAssigned"
  }

  # connection_string {
  #   name  = "db"
  #   type  = "SQLServer"
  #   value = data.azurerm_key_vault_secret.connection_string.value
  # }
}

resource "azurerm_monitor_autoscale_setting" "appserviceplan_autoscale" {
  name                = "autoscale-plan-calicot-dev-${var.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.web.name

  target_resource_id = azurerm_service_plan.appserviceplan.id

  profile {
    name = "DefaultProfile"
    capacity {
      minimum = 1
      default = 1
      maximum = 2
    }

    # Scale out if average CPU > 70%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    # Scale in if average CPU < 30%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_service_plan.appserviceplan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
      custom_emails                         = []
    }
  }
}


resource "azurerm_mssql_server" "sqlserver" {
  name                         = "sqlsrv-calicot-dev-${var.suffix}"
  resource_group_name          = data.azurerm_resource_group.web.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "sqldb" {
  name         = "sqldb-calicot-dev-${var.suffix}"
  server_id    = azurerm_mssql_server.sqlserver.id
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-calicot-dev-${var.suffix}"
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.web.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    secret_permissions = [
      "Get",
      "List",
    ]

    key_permissions = [
      "Get",
      "List",
    ]

    certificate_permissions = [
      "Get",
      "List",
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "access_policy" {
#   key_vault_id = azurerm_key_vault.example.id
#   tenant_id    = var.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "Get",
#     "List"
#   ]

#   secret_permissions = [
#     "Get",
#     "List"
#   ]
# }

data "azurerm_key_vault_secret" "connection_string" {
  name         = "ConnectionStrings"
  key_vault_id = azurerm_key_vault.kv.id
}
