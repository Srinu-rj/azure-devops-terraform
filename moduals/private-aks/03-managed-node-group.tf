resource "azurerm_kubernetes_cluster_node_pool" "cluster_node_pool" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster_backend.id
  vm_size               = "Standard_D2s_v3"
  os_type               = "Linux"
  mode                  = "User"
  priority              = "Spot"
  enable_auto_scaling   = true
  spot_max_price        = -1
  node_count            = 1
  min_count             = 1
  max_count             = 10
  os_disk_type          = "Ephemeral"
  vnet_subnet_id = data.azurerm_subnet.aks_subnet.id

  node_labels = {
    role                                    = "spot"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "spot:NoSchedule",
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}
