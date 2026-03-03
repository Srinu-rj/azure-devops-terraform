data "azurerm_subscription" "current" {}
data "azuread_service_principal" "service_principal" {}

# Custom role for Terraform
resource "azurerm_role_definition" "terraform" {
  name        = "Terraform Deployer"
  scope       = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  description = "Custom role for Terraform with minimal permissions"

  permissions {
    actions = [
      # Compute
      "Microsoft.Compute/virtualMachines/*",
      "Microsoft.Compute/disks/*",
      "Microsoft.Compute/availabilitySets/*",

      # Networking
      "Microsoft.Network/virtualNetworks/*",
      "Microsoft.Network/networkSecurityGroups/*",
      "Microsoft.Network/publicIPAddresses/*",
      "Microsoft.Network/loadBalancers/*",

      # Storage
      "Microsoft.Storage/storageAccounts/*",

      # Resource groups
      "Microsoft.Resources/subscriptions/resourceGroups/read",

      # Required for state management
      "Microsoft.Storage/storageAccounts/blobServices/containers/*"
    ]

    not_actions = [
      # Explicitly deny dangerous operations
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleDefinitions/write"
    ]
  }

  assignable_scopes = [
    "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  ]
}

# Assign the custom role to Terraform's service principal
resource "azurerm_role_assignment" "terraform" {
  scope              = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_id = azurerm_role_definition.terraform.role_definition_resource_id
  principal_id       = data.azuread_service_principal.service_principal.object_id
}