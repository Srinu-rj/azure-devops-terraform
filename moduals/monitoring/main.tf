data "azurerm_resource_group" "" {
  name = "" #resource name
}

#TODO: Basic Log Alert Rules
#TODO:  Alert on application errors in the last 5 minutes
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_errors" {
  name                = "app-error-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert when application error count exceeds threshold"
  severity            = 2
  enabled             = true

  scopes                  = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M"

  criteria {
    query = <<-KQL
      AppExceptions
      | where TimeGenerated > ago(5m)
      | summarize ErrorCount = count() by bin(TimeGenerated, 5m)
    KQL

    time_aggregation_method = "Total"
    operator                = "GreaterThan"
    threshold               = 10
    metric_measure_column   = "ErrorCount"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

#TODO: Security Event Alert
# Alert on failed login attempts
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_logins" {
  name                = "failed-login-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert on excessive failed login attempts"
  severity            = 1
  enabled             = true

  scopes               = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query = <<-KQL
      SigninLogs
      | where TimeGenerated > ago(15m)
      | where ResultType != "0"
      | summarize FailedCount = count() by UserPrincipalName, IPAddress
      | where FailedCount > 5
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

#TODO: Resource Health Alerts
# Alert when resources report errors
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "resource_errors" {
  name                = "resource-error-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert on resource-level errors in Azure Activity Log"
  severity            = 2
  enabled             = true

  scopes               = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<-KQL
      AzureActivity
      | where TimeGenerated > ago(5m)
      | where Level == "Error"
      | summarize ErrorCount = count() by ResourceGroup, ResourceProviderValue, _ResourceId
      | where ErrorCount > 0
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

#TODO: Alert on custom application logs
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "custom_app_alert" {
  name                = "payment-failure-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert on payment processing failures"
  severity            = 1
  enabled             = true

  scopes               = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  criteria {
    query = <<-KQL
      AppTraces
      | where TimeGenerated > ago(5m)
      | where Message contains "PaymentProcessingFailed"
      | summarize FailureCount = count() by bin(TimeGenerated, 5m)
    KQL

    time_aggregation_method = "Total"
    operator                = "GreaterThan"
    threshold               = 5
    metric_measure_column   = "FailureCount"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

#TODO ==> Alert when expected heartbeat data stops arriving
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "missing_heartbeat" {
  name                = "missing-heartbeat-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert when agent heartbeat data is missing"
  severity            = 1
  enabled             = true

  scopes               = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT10M"

  criteria {
    query = <<-KQL
      Heartbeat
      | summarize LastHeartbeat = max(TimeGenerated) by Computer
      | where LastHeartbeat < ago(10m)
      | project Computer, LastHeartbeat, MinutesSinceLastBeat = datetime_diff('minute', now(), LastHeartbeat)
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

#TODO ==> Alert when API response times degrade
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "slow_api" {
  name                = "slow-api-response"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = azurerm_resource_group.monitoring.location
  description         = "Alert when API response times exceed threshold"
  severity            = 2
  enabled             = true

  scopes               = [data.azurerm_log_analytics_workspace.main.id]
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"

  criteria {
    query = <<-KQL
      AppRequests
      | where TimeGenerated > ago(15m)
      | where Success == true
      | summarize
          AvgDuration = avg(DurationMs),
          P95Duration = percentile(DurationMs, 95),
          RequestCount = count()
        by bin(TimeGenerated, 5m)
      | where P95Duration > 3000 and RequestCount > 10
    KQL

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 2
      number_of_evaluation_periods             = 3
    }
  }

  action {
    action_groups = [data.azurerm_monitor_action_group.ops.id]
  }
}

