provider "azurerm" {

    features {
      # Enable Key Vault soft delete recovery features
      key_vault {
        purge_soft_delete_on_destroy = true
        recover_soft_deleted_key_vaults = true
      }

    }
    subscription_id = "25e8c454-3a15-4844-8f5b-c9998fd32ba9"
    tenant_id       ="34e85fbe-21e0-4cd5-9c11-37b6604608f0"
    client_id       = "04ca8ecf-36eb-43e3-a479-eaa41904e984"
    client_secret   = "PRg8Q~HbW4f.w5BI5o3R_i~Hyc4KzVY3zat74dta"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

  }
}