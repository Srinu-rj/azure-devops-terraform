resource "azurerm_resource_group" "devops" {
  location = var.location
  name     = var.resource_group_name
}