resource "azurerm_service_plan" "app" {
  name                = "asp-secure-web-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  os_type  = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "nelson-secure-web-app"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app.id

  identity {
    type = "SystemAssigned"
  }

  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  site_config {
    always_on              = false
    ftps_state             = "FtpsOnly"
    vnet_route_all_enabled = true

    application_stack {
      python_version = "3.14"
    }
  }

  app_settings = {
    SQL_SERVER    = azurerm_mssql_server.sql.fully_qualified_domain_name
    SQL_DATABASE  = azurerm_mssql_database.app.name
    KEY_VAULT_URL = azurerm_key_vault.app.vault_uri

    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app.connection_string
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "1"
  }

  https_only = true

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id,
      tags,
      app_settings["APPLICATIONINSIGHTS_CONNECTION_STRING"],
      site_config[0].ip_restriction_default_action,
      site_config[0].scm_ip_restriction_default_action
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.app.id
}