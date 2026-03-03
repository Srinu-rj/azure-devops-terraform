  # resource "kubernetes_namespace_v1" "argocd_namespace" {
  #   metadata {
  #     name = "argocd"
  #     labels = {
  #       "managed-by" = "terraform"
  #     }
  #   }
  # }
  #
  # resource "helm_release" "argocd" {
  #   name              = "argocd"
  #   repository        = "https://argoproj.github.io/argo-helm"
  #   chart             = "argo-cd"
  #   version           = "9.4.3" # TODO -> pin version — check ArtifactHub
  #   namespace         = kubernetes_namespace_v1.argocd_namespace.metadata[0].name
  #   wait              = true
  #   timeout           = 1800
  #   atomic            = true
  #   cleanup_on_fail   = true
  #   dependency_update = true
  #   create_namespace  = false # Since Terraform already creates it, this avoids Helm drift or race conditions.
  #
  #
  #   # ✅ Helm provider v3.x — set is now a list argument, NOT a block
  #   set = [
  #     {
  #       name  = "server.extraArgs[0]"
  #       value = "--insecure"
  #     },
  #     {
  #       name  = "server.replicas"
  #       value = "1"
  #       type  = "auto"
  #     },
  #     {
  #       name  = "repoServer.replicas"
  #       value = "1"
  #       type  = "auto"
  #     },
  #     {
  #       name  = "server.metrics.enabled"
  #       value = "true"
  #       type  = "auto"
  #     },
  #     {
  #       name  = "repoServer.metrics.enabled"
  #       value = "true"
  #       type  = "auto"
  #     },
  #     {
  #       name  = "installCRDs"
  #       value = "true"
  #       type  = "auto"
  #     },
  #     {
  #       name  = "server.resources.requests.cpu"
  #       value = "100m"
  #     },
  #     {
  #       name  = "server.resources.requests.memory"
  #       value = "256Mi"
  #     },
  #     {
  #       name  = "server.resources.limits.cpu"
  #       value = "500m"
  #     },
  #     {
  #       name  = "server.resources.limits.memory"
  #       value = "512Mi"
  #     }
  #   ]
  #
  #   depends_on = [
  #     kubernetes_namespace_v1.argocd_namespace,
  #     azurerm_kubernetes_cluster.aks_cluster_backend
  #   ]
  #
  # }
  #
  #
  #
