#Create a key vault
resource "azurerm_key_vault" "example_vault" {
  name                       = "acr-key-vault"
  location                   = "West Europe"
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = "34e85fbe-21e0-4cd5-9c11-37b6604608f0"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name                   = "standard"

  access_policy {
    tenant_id = "34e85fbe-21e0-4cd5-9c11-37b6604608f0"
    object_id = "db2f2d01-f423-4e65-9861-d09cc14fd049"
    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
      "recover",
      "backup",
      "restore"
    ]
  }
}

