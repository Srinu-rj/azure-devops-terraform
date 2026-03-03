#TODO==> Get the current subscription
data "azurerm_subscription" "current" {}

# ==================================================
# TODO==> Create a subscription-level budget ✅ BEST
# ==================================================
resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "monthly-subscription-budget"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 5000
  time_grain = "Monthly"

  time_period {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }

  # Alert at 80%
  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 80
    threshold_type = "Actual"

    contact_emails = [
      "dnsrinu143@gmail.com",
      "dnsrinu143@gmail.com",
    ]
  }

  # Alert at 100%
  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    threshold_type = "Actual"

    contact_emails = [
      "dnsrinu143@gmail.com",
      "dhenuvakondasreenivasaraju@gmail.com",
    ]
  }

  # Forecasted alert
  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    threshold_type = "Forecasted"

    contact_emails = [
      "dnsrinu143@gmail.com",
    ]
  }
}

# ==================================================
# TODO==> Resource Group Budget  ==> ✅ BEST
# ==================================================
resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "cost-alert-group"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "CostAlerts"

  email_receiver {
    name          = "finance"
    email_address = "finance@company.com"
  }
  webhook_receiver {
    name        = "slack"
    service_uri = var.slack_webhook_url
  }
  sms_receiver {
    name         = "oncall"
    country_code = "91"
    phone_number = "9642266933"
  }

}

# Budget with action group
resource "azurerm_consumption_budget_subscription" "with_actions" {
  name            = "budget-with-actions"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 5000
  time_grain = "Monthly"

  time_period {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }

  notification {
    enabled   = true
    operator  = "GreaterThan"
    threshold = 90

    contact_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }
}


# ==============================================================================
# TODO ==> Create an action group for cost alerts [BUDGET WITH ACTION GROUPS ]
# ==============================================================================
resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "cost-alert-group"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "CostAlerts"

  email_receiver {
    name          = "finance"
    email_address = "finance@company.com"
  }

  webhook_receiver {
    name        = "slack"
    service_uri = var.slack_webhook_url
  }

  sms_receiver {
    name         = "oncall"
    country_code = "91"
    phone_number = "9642266933"
  }
}

# Budget with action group
resource "azurerm_consumption_budget_subscription" "with_actions" {
  name            = "budget-with-actions"
  subscription_id = data.azurerm_subscription.current.id

  amount     = 5000
  time_grain = "Monthly"

  time_period {
    start_date = "2026-01-01T00:00:00Z"
    end_date   = "2027-01-01T00:00:00Z"
  }

  notification {
    enabled   = true
    operator  = "GreaterThan"
    threshold = 90

    contact_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }
}


# =====================================================================================================
# TODO ==> Create a cost anomaly alert using Azure Monitor [ Set Up Alerts for Unexpected Cost Spikes]
# ======================================================================================================
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "cost_anomaly" {
  name                = "cost-anomaly-alert"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = "eastus"

  evaluation_frequency = "P1D"
  window_duration      = "P1D"
  scopes               = [data.azurerm_subscription.current.id]

  severity = 2

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where Category == "Costs"
      | summarize DailyCost = sum(todouble(cost_s)) by bin(TimeGenerated, 1d)
      | extend AvgCost = avg(DailyCost)
      | where DailyCost > AvgCost * 1.5
    QUERY

    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }
}