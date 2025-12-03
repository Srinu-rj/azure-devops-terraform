resource "azurerm_resource_group" "datadog-rg" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_dns_zone" "example-public" {
  name                = "mydomain.com"
  resource_group_name = "srinu"
}