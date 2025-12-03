resource "azurerm_resource_group" "datadog-rg" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_datadog_monitor" "data-dog-monitor" {
  location            = var.location
  name                = var.datadog_monitor_name
  resource_group_name = azurerm_resource_group.datadog-rg.name

  datadog_organization {
    api_key         = var.api_key
    application_key = var.application_key
  }
  user {
    email = var.data_dog_email_id  #"dnsrinuraju@gmail.com"
    name  = var.data_dog_user_name #"srinu"
  }

  sku_name = "Linked"
  identity {
    type = "SystemAssigned"
  }


}
