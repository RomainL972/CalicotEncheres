# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "plan-calicot-${var.deployment_type}-${var.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.web.name
  os_type             = "Linux"
  sku_name            = "S1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-calicot-${var.deployment_type}-${var.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.web.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  depends_on          = [azurerm_service_plan.appserviceplan]
  https_only          = true

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

  connection_string {
    name  = "db"
    type  = "SQLServer"
    value = data.azurerm_key_vault_secret.connection_string.value
  }
}

resource "azurerm_monitor_autoscale_setting" "appserviceplan_autoscale" {
  name                = "autoscale-plan-calicot-${var.deployment_type}-${var.suffix}"
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
        metric_name        = "CpuPercentage"
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
        metric_name        = "CpuPercentage"
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
