resource "azurerm_monitor_action_group" "app_alerts" {
  name                = "ag-secure-web-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "SecureWebAlr"

  email_receiver {
    name                    = "Email0_-EmailAction-"
    email_address           = var.alert_email_address
    use_common_alert_schema = true
  }

  lifecycle {
    ignore_changes = [
      email_receiver[0].email_address
    ]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "http_errors" {
  name                = "alert-web-http-errors"
  display_name        = "alert-web-http-errors"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  scopes = [
    azurerm_log_analytics_workspace.app.id
  ]

  description = "Alerts when more than 3 failed HTTP requests occur within a 5-minute period."

  severity                = 2
  enabled                 = true
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M"
  auto_mitigation_enabled = false

  target_resource_types = [
    "Microsoft.OperationalInsights/workspaces"
  ]

  criteria {
    query = "AppRequests\n| where Success == false or toint(ResultCode) >= 400\n"

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 3
    resource_id_column      = "_ResourceId"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [
      replace(
        replace(
          azurerm_monitor_action_group.app_alerts.id,
          "Microsoft.Insights",
          "microsoft.insights"
        ),
        "actionGroups",
        "actiongroups"
      )
    ]
  }
}