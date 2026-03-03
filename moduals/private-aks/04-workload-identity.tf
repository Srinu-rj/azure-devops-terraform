data "azurerm_resource_group" "aks_rg" {
  name = "aks-rg"
}
resource "azurerm_user_assigned_identity" "dev_test" {
  name                = "dev-test"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}

resource "azurerm_federated_identity_credential" "dev_test" {
  name                = "dev-test"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks_cluster_backend.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.dev_test.id
  subject             = "system:serviceaccount:dev:my-account"

  depends_on = [azurerm_kubernetes_cluster.aks_cluster_backend]

}
