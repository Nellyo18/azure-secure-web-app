resource "azurerm_service_plan" "app" {
  name                = "asp-secure-web-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "nelson-secure-web-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.14"
    }

    ftps_state = "Disabled"
  }

  app_settings = {
    SQL_DATABASE  = "sqldb-secure-web-prod"
    KEY_VAULT_URL = "https://kv-secure-web-nelson.vault.azure.net/"
  }

  https_only = true
}

resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.app.id
}
