resource "azurerm_resource_group" "api_rg" {
  location = var.api_rg_location
  name     = var.api_rg_name
}

# CREATE THE APIM INSTANCE
resource "azurerm_api_management" "rest_api_management" {
  name                = var.asp_net_api_managerment
  publisher_email     = "dnsrinu143@gmail.com"
  publisher_name      = "viveja"
  location            = azurerm_resource_group.api_rg.location
  resource_group_name = azurerm_resource_group.api_rg.name
  sku_name            = "Developer_1"

  identity {
    type = "SystemAssigend"
  }

  # virtual network integration
  virtual_network_type = "Internal" #  OR External
  # Minium TLS Version
  min_api_version = "2019-12-01"

}
#TODO ==> Configuring Application Insights Logger
resource "azurerm_application_insights" "api_insights" {
  name                = var.api_application_insights_name
  application_type    = "web"
  location            = azurerm_resource_group.api_rg.location
  resource_group_name = azurerm_resource_group.api_rg.name
}
resource "azurerm_api_management_logger" "api_management_logger" {
  name                = var.api_management_logger_insights
  api_management_name = azurerm_api_management.rest_api_management.name
  resource_group_name = azurerm_resource_group.api_rg.name

  application_insights {
    instrumentation_key = azurerm_application_insights.api_insights.instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "api_management_diagnostic" {
  identifier               = "applicationInsights"
  api_management_logger_id = azurerm_api_management_logger.api_management_logger.id
  api_management_name      = azurerm_api_management.rest_api_management.name
  resource_group_name      = azurerm_resource_group.api_rg.name

  sampling_percentage = 100

  always_log_errors = true
  log_client_ip = true
  verbosity = "information"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "Content_Type",
      "User"
    ]
  }
}









































