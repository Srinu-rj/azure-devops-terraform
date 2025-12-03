resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

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

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Premium"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.example.id
    ]
  }

  encryption {
    key_vault_key_id   = data.azurerm_key_vault_key.example_vault.
    identity_client_id = azurerm_user_assigned_identity.example.client_id
  }

}

resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  name = "registry-uai"
}

