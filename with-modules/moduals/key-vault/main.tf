terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }
}
data "azurerm_resource_group" "aks_rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "aks_kv" {
  name                        = var.AKS_KEY_VAULT_NAME
  location                    = data.azurerm_resource_group.aks_rg.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
    storage_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
    ]
  }

  tags = {
    Environment = "Production"
    Project     = "AKS Cluster"
  }
}
resource "azurerm_key_vault_secret" "example" {
  name         = var.VAULT_USER_NAME   # TODO like sql username
  value        = var.VAULT_VALUE       # TODO like sql password
  key_vault_id = azurerm_key_vault.aks_kv.id
}

