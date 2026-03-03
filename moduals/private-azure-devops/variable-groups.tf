# Variable groups store values that can be shared across multiple pipelines:
# Variable group for common settings
resource "azuredevops_variable_group" "docker_variables" {
  project_id   = azuredevops_project.main.id
  name         = "common-variables"
  description  = "Common variables shared across pipelines"
  allow_access = true # Allow pipeline

  variable {
    name  = "ENVIRONMENT"
    value = "production"
  }
  variable {
    name  = "REGION"
    value = "eastus"
  }
  variable {
    name  = "DOCKER_REGISTRY"
    value = "myacr.azurecr.io"
  }
  #TODO  Variable group linked to Azure Key Vault
  key_vault {
    name                = "kv-devops-prod"
    service_endpoint_id = azuredevops_serviceendpoint_azurerm.production.id
  }
}


