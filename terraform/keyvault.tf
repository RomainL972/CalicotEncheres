resource "azurerm_key_vault" "kv" {
  name                = "kv-calicot-${var.deployment_type}-${var.suffix}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.web.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }
}

data "azurerm_key_vault_secret" "connection_string" {
  name         = "ConnectionStrings"
  key_vault_id = azurerm_key_vault.kv.id
}
