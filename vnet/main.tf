resource "azurerm_resource_group" "resource_group_vnet" {
  name     = var.resource_group_vnet
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  location            = var.location
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.resource_group_vnet.name
}

