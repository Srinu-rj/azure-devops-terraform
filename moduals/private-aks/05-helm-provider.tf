provider "kubernetes" {
  config_path    = "~/.kube/config"          # or use EKS/GKE data sources
  config_context = "my-cluster-context"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "my-cluster-context"
  }
}
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster_backend.kube_config[0].cluster_ca_certificate)
  }
}