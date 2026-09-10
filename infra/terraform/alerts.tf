resource "azurerm_monitor_action_group" "app_alerts" {
  name                = "ag-secure-web-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "SecureWebAlr"

  email_receiver {
    name                    = "primary-email"
    email_address           = var.alert_email_address
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "http_errors" {
  name                = "alert-web-http-errors"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  scopes = [
    azurerm_log_analytics_workspace.app.id
  ]

  description = "Alerts when more than 3 failed HTTP requests occur within a 5-minute period."

  severity             = 2
  enabled              = true
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<-KQL
      AppRequests
      | where Success == false or toint(ResultCode) >= 400
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 3
  }

  action {
    action_groups = [
      azurerm_monitor_action_group.app_alerts.id
    ]
  }

  auto_mitigation_enabled = true
}
