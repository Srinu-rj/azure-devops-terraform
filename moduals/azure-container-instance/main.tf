locals {
  server_less_rg_name = var.server_less_rg_name
  rg_location         = var.rg_location
}

data "azurerm_resource_group" "aks-rg" {
  name = "aks-rg"
}
resource "azurerm_resource_group" "azure_container_apps" {
  name     = local.server_less_rg_name
  location = local.rg_location
}
resource "azurerm_log_analytics_workspace" "container_app_analytics" {
  name                = "containerappanalytics"
  location            = azurerm_resource_group.azure_container_apps.location
  resource_group_name = azurerm_resource_group.azure_container_apps.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "container_app_environment" {
  name                       = "springcontainerappenvironment"
  location            = azurerm_resource_group.azure_container_apps.location
  resource_group_name = azurerm_resource_group.azure_container_apps.name
  # logs_destination           = "loganalytics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container_app_analytics.id
}

resource "azurerm_container_app" "app" {
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  name                         = "springboot-app"
  resource_group_name = azurerm_resource_group.azure_container_apps.name
  revision_mode                = "Multiple"
  template {
    container {
      cpu    = 1                            #Allocate number of cpus
      image  = "mcr.microsoft.com/k8se/quickstart:latest" #TODO Add your ACR image path here
      memory = "1.5Gi"
      name   = "springacrcontaineraapp"     #TODO SHOW BE MATCH WITH ACR NAME
    }
  }
  ingress {
    allow_insecure_connections = false
    target_port                = 1199
    external                   = true
    traffic_weight {
      percentage = 100
    }
  }
}

resource "azurerm_storage_account" "container_storage" {
  account_replication_type = ""
  account_tier             = ""
  name                     = var.aci_storage_account
  location            = azurerm_resource_group.azure_container_apps.location
  resource_group_name = azurerm_resource_group.azure_container_apps.name
}

resource "azurerm_storage_share" "storage_share" {
  name  = var.storage_share
  quota = 50
  storage_account_id = azurerm_storage_account.container_storage.id
  acl {
    id = "" # storage access id
  }
  access_policy {
    permissions = "rwdl"
    start       = "2019-07-02T09:38:21Z"
    expiry      = "2019-07-02T10:38:21Z"
  }
}

resource "azurerm_container_app_environment_storage" "" {
  access_mode                  = "ReadWrite" # ReadOnly or ReadWrite
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  name                         = var.storage_share_name
  share_name                   = azurerm_storage_share.storage_share.name
}