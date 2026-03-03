data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}


resource "azuredevops_serviceendpoint_aws" "aws_service_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example AWS"
  access_key_id         = "00000000-0000-0000-0000-000000000000"
  secret_access_key     = "accesskey"
  description           = "Managed by AzureDevOps"
}

resource "azuredevops_serviceendpoint_kubernetes" "azure_kubernetes_cluster_endpoint" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example Kubernetes"
  apiserver_url         = "https://sample-kubernetes-cluster.hcp.westeurope.azmk8s.io"
  authorization_type    = "AzureSubscription"

  azure_subscription {
    subscription_id   = "00000000-0000-0000-0000-000000000000"
    subscription_name = "Example"
    tenant_id         = "00000000-0000-0000-0000-000000000000"
    resourcegroup_id  = "example-rg"
    namespace         = "default"
    cluster_name      = "example-aks"
  }
}
resource "azuredevops_serviceendpoint_kubernetes" "azure_kubernetes_cluster_endpoint_token_based" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Example Kubernetes"
  apiserver_url         = "https://sample-kubernetes-cluster.hcp.westeurope.azmk8s.io"
  authorization_type    = "ServiceAccount"

  service_account {
    token   = "000000000000000000000000"
    ca_cert = "0000000000000000000000000000000"
  }
}


# Azure Resource Manager service connection using service principal
resource "azuredevops_serviceendpoint_azurerm" "production" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "Azure Production"
  description           = "Service connection to Azure Production subscription"

  azurerm_spn_tenantid      = data.azurerm_client_config.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = "Production Subscription"

  credentials {
    serviceprincipalid  = var.sp_client_id
    serviceprincipalkey = var.sp_client_secret
  }
}

variable "sp_client_id" {
  type      = string
  sensitive = true
}

variable "sp_client_secret" {
  type      = string
  sensitive = true
}

# Docker Registry service connection
resource "azuredevops_serviceendpoint_dockerregistry" "acr" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "ACR Production"
  docker_registry       = "https://myacr.azurecr.io"
  docker_username       = var.acr_username
  docker_password       = var.acr_password
  registry_type         = "Others"
}

variable "acr_username" {
  type      = string
  sensitive = true
}

variable "acr_password" {
  type      = string
  sensitive = true
}

# GitHub service connection
resource "azuredevops_serviceendpoint_github" "github" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "GitHub"

  auth_personal {
    personal_access_token = var.github_pat
  }
}

variable "github_pat" {
  type      = string
  sensitive = true
}