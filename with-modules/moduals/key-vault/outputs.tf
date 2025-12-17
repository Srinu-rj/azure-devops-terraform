data "azurerm_key_vault" "example" {
  name                = var.AKS_KEY_VAULT_NAME
  resource_group_name = var.resource_group_name
}
output "vault_uri" {
  value = data.azurerm_key_vault.example.vault_uri
}


data "azurerm_key_vault_key" "example" {
  name         = "secret-sauce"
  key_vault_id = data.azurerm_key_vault.example.id
}
output "key_type" {
  value = data.azurerm_key_vault_key.example.key_type
}