resource "azurerm_resource_group" "dns_rg" {
  for_each = var.dns_env
  name     = each.value.name
  location = each.value.location
  tags = {
    environment = each.key
    managed_by  = "terraform"
  }
}
resource "azurerm_dns_zone" "dns_zone" {
  for_each = var.dns_env
  name                = each.value.domain_name
  resource_group_name = azurerm_resource_group.dns_rg[each.key].name
}
resource "azurerm_dns_a_record" "example" {
  for_each = var.dns_env
  name                = each.value.dns_a_record
  zone_name           = azurerm_dns_zone.dns_zone[each.key].name
  resource_group_name = azurerm_resource_group.dns_rg[each.key].name
  ttl                 = 300
  records             = each.value.ip_address
}