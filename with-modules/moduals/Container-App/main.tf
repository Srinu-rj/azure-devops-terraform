data "azurerm_resource_group" "aks-rg" {
  name = "aks-rg"
}

resource "azurerm_log_analytics_workspace" "container_app_analytics" {
  name                = "container_app_analytics"
  location            = data.azurerm_resource_group.aks-rg.location
  resource_group_name = data.azurerm_resource_group.aks-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "container_app_environment" {
  name                       = "spring_container_app_environment"
  location                   = data.azurerm_resource_group.aks-rg.location
  resource_group_name        = data.azurerm_resource_group.aks-rg.name
  logs_destination           = "log-analytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container_app_analytics.id
}

resource "azurerm_container_app" "app" {
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  name                         = "springboot-app"
  resource_group_name          = data.azurerm_resource_group.aks-rg.name
  revision_mode                = "Multiple"
  template {
    container {
      cpu    = 1
      image  = ""  #TODO Add your ACR image path here
      memory = "0.5Gi"
      name   = "springacrcontaineraapp" #TODO SHOW BE MATCH WITH ACR NAME
    }
  }
  ingress {
    allow_insecure_connections = false
    target_port = 1199
    external    = true
    traffic_weight {
      percentage = 100
    }
  }
}
