resource "azurerm_resource_group" "container_apps" {
  location = var.location
  name     = var.container_rg_name
}

resource "azurerm_log_analytics_workspace" "app_analytics_job" {
  name                = var.log_analytics_name
  location            = var.log_analytics_location
  resource_group_name = var.log_analytics_rg
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
}

resource "azurerm_container_app_environment" "container_app_environment_jobs" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.container_apps.location
  resource_group_name        = azurerm_resource_group.container_apps.name
  logs_destination           = var.logs_destination
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app_analytics_job.id
}

resource "azurerm_container_app_job" "spring_container_app_jobs" {
  name                         = var.container_job
  location                     = azurerm_resource_group.container_apps.location
  resource_group_name          = azurerm_resource_group.container_apps.name
  container_app_environment_id = azurerm_container_app_environment.container_app_environment_jobs.id

  replica_timeout_in_seconds = var.replica_timeout
  replica_retry_limit        = var.replica_retry_limit

  manual_trigger_config {
    parallelism              = var.parallelism
    replica_completion_count = var.replica_completion_count
  }

  template {
    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      readiness_probe {
        transport = var.readiness_transport
        port      = var.readiness_port
      }

      liveness_probe {
        transport = var.liveness_transport
        port      = var.liveness_port
        path      = var.liveness_path

        header {
          name  = var.liveness_header_name
          value = var.liveness_header_value
        }

        initial_delay           = var.liveness_initial_delay
        interval_seconds        = var.liveness_interval
        timeout                 = var.liveness_timeout
        failure_count_threshold = var.liveness_failure_threshold
      }

      startup_probe {
        transport = var.startup_transport
        port      = var.startup_port
      }
    }
  }
}
