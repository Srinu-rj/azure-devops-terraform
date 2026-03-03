resource "azurerm_resource_group" "vnet_rg" {
  for_each = var.environments
  location = "vnet_rg-${each.key}"
  name     = each.value.location

  tags = {
    env= each.value.tag_env
  }
}
resource "azurerm_network_ddos_protection_plan" "vnet_ddos" {
  for_each = var.environments
  name                = "vnet_ddos-${each.key}"
  location            = azurerm_resource_group.vnet_rg[each.key].location
  resource_group_name = azurerm_resource_group.vnet_rg[each.key].name

  tags = {
    env= each.value.tag_env
  }
}