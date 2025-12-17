
resource "azurerm_resource_group" "acr_rg" {
  location = var.ACR_LOCATION
  name     = var.ACR_RG_NAME
}

resource "azurerm_resource_group" "aks_rg" {
  location = var.AKS_LOCATION
  name     = var.AKS_RG_NAME
}

