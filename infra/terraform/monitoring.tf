resource "azurerm_log_analytics_workspace" "app" {
  name                = "law-secure-web-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  sku               = "PerGB2018"
  retention_in_days = 30

  lifecycle {
    ignore_changes = [
      local_authentication_enabled
    ]
  }
}

resource "azurerm_application_insights" "app" {
  name                = "appi-secure-web-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.app.id
  sampling_percentage = 0
}