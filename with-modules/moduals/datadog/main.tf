data "azurerm_resource_group" "rg" {
  name     = "rg-vnet-001"
}

# Create a new Datadog - Microsoft Azure integration
resource "datadog_integration_azure" "sandbox" {
  tenant_name              = "<azure_tenant_name>"
  client_id                = "<azure_client_id>"
  client_secret            = "<azure_client_secret_key>"
  host_filters             = "examplefilter:true,example:true"
  app_service_plan_filters = "examplefilter:true,example:another"
  container_app_filters    = "examplefilter:true,example:one_more"
  automute                 = true
  cspm_enabled             = true
  custom_metrics_enabled   = false
}

resource "azurerm_datadog_monitor" "example" {
  name                = "example-monitor"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  datadog_organization {
    api_key         = "XXXX"
    application_key = "XXXX"
  }
  user {
    name  = "Example"
    email = "abc@xyz.com"
  }
  sku_name = "Linked"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_datadog_monitor_sso_configuration" "example" {
  datadog_monitor_id        = azurerm_datadog_monitor.example.id
  single_sign_on            = "Enable"
  enterprise_application_id = "00000000-0000-0000-0000-000000000000"
}