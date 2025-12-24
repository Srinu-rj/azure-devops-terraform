locals {
  cdn_rg_location  = var.cdn_rg_location
  cdn_rg_name      = var.cdn_rg_name
  cdn_profile_name = var.cdn_profile_name
  cdn_sku          = var.cdn_sku
}
resource "azurerm_resource_group" "cdn_rg" {
  location = local.cdn_rg_location
  name     = local.cdn_rg_name
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = local.cdn_profile_name
  location            = azurerm_resource_group.cdn_rg.location
  resource_group_name = azurerm_resource_group.cdn_rg.name
  sku                 = local.cdn_sku
}

