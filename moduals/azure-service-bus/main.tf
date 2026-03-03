resource "azurerm_resource_group" "service_bus_rg" {
  name     = "terraform-servicebus"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "service_bus_ns" {
  name                = "tfex-servicebus-namespace"
  location            = azurerm_resource_group.service_bus_rg.location
  resource_group_name = azurerm_resource_group.service_bus_rg.name
  sku                 = "Standard"

}

resource "azurerm_servicebus_namespace_authorization_rule" "service_bus_ns_authorization_rule" {
  name         = "examplerule"
  namespace_id = azurerm_servicebus_namespace.service_bus_ns.id

  listen = true
  send   = true
  manage = false
}
