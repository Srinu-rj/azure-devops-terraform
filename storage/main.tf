resource "azurerm_resource_group" "example" {
  name     = var.RESOURCE_GROUP
  location = var.LOCATION
}

# Create a storage account
resource "azurerm_storage_account" "srinu143raju" {
  name                     = var.STORAGE_NAME
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}
