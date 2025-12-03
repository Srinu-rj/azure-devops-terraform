locals {
  resource_group= "srinu-devops-azure-rg"
  location= "centralindia"
}
resource "azurerm_resource_group" "example" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
