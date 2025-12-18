data "azurerm_resource_group" "aks-rg" {
  name = "aks-rg"
}

resource "azurerm_service_plan" "azure_plan" {
  location            = data.azurerm_resource_group.aks-rg.location
  name                = var.app_service_plan
  os_type             = ""
  resource_group_name = data.azurerm_resource_group.aks-rg.name
  sku_name            = var.service_plan_sku
}

resource "azurerm_linux_web_app" "backend_app_deployment" {
  location            = data.azurerm_resource_group.aks-rg.location
  name                = var.web_app_name
  resource_group_name = data.azurerm_resource_group.aks-rg.name
  service_plan_id     = azurerm_service_plan.azure_plan.id

  site_config {}
}

