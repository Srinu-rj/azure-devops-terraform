terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

#TODO  az ad sp create-for-rbac --name terraform-sp --role Contributor --scopes /subscriptions/5c13e26b-0015-4f32-aace-8ea1b3236fd8
#TODO  az ad sp create-for-rbac --name terraform-sp --role="Contributor" --scopes="/subscriptions/<your-subscription-id>"





