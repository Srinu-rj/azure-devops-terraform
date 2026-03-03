resource "kubernetes_namespace_v1" "argo_rollouts" {
  metadata {
    name = "argo-rollouts"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "argo-rollouts"
    }
  }
}

resource "helm_release" "argo_rollouts" {
  name              = "argo-rollouts"
  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-rollouts"
  version           = "2.35.1"               # ← check latest on ArtifactHub
  namespace         = kubernetes_namespace_v1.argo_rollouts.metadata[0].name
  wait              = true
  timeout           = 1900
  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true

  set = [

    # ── Controller ───────────────────────────────────────────
    {
      name  = "controller.replicas"
      value = "2"
      type  = "auto"                         # ✅ integer
    },

    # ── CRDs ─────────────────────────────────────────────────
    {
      name  = "installCRDs"
      value = "true"
      type  = "auto"                         # ✅ boolean
    },

    # ── Dashboard UI ─────────────────────────────────────────
    {
      name  = "dashboard.enabled"
      value = "true"
      type  = "auto"                         # ✅ boolean
    },
    {
      name  = "dashboard.replicas"
      value = "1"
      type  = "auto"                         # ✅ integer
    },
    {
      name  = "dashboard.service.type"
      value = "ClusterIP"                    # plain string — no type needed
    },

    # ── Prometheus Metrics ───────────────────────────────────
    {
      name  = "controller.metrics.enabled"
      value = "true"
      type  = "auto"                         # ✅ boolean
    },
    {
      name  = "serviceMonitor.enabled"
      value = "true"
      type  = "auto"                         # ✅ boolean
    },
    {
      name  = "notifications.enabled"
      value = "true"
      type  = "auto"                         # ✅ boolean
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.cert_manager_namespace,
    azurerm_kubernetes_cluster.aks_cluster_backend
  ]
}

###############################################################
# Ingress — Argo Rollouts Dashboard
# Using HAProxy (consistent with cluster ingress setup)
###############################################################

resource "kubernetes_ingress_v1" "argo_rollouts_dashboard" {
  metadata {
    name      = "argo-rollouts-dashboard"
    namespace = kubernetes_namespace_v1.argo_rollouts.metadata[0].name

    annotations = {
      "cert-manager.io/cluster-issuer"          = "letsencrypt-staging"
      "haproxy-ingress.github.io/ssl-redirect"  = "true"
    }
  }

  spec {
    ingress_class_name = "haproxy"

    tls {
      hosts       = ["rollouts.example.com"]   # ← change to your domain
      secret_name = "argo-rollouts-tls"
    }

    rule {
      host = "rollouts.example.com"            # ← change to your domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-rollouts-dashboard"
              port {
                number = 3100
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.cert_manager_namespace,
    azurerm_kubernetes_cluster.aks_cluster_backend
  ]

}


###############################################################
# Outputs
###############################################################

# output "argo_rollouts_namespace" {
#   description = "Namespace where Argo Rollouts is installed"
#   value       = kubernetes_namespace_v1.argo_rollouts.metadata[0].name
# }
#
# output "argo_rollouts_version" {
#   description = "Installed chart version"
#   value       = helm_release.argo_rollouts.version
# }
#
# output "argo_rollouts_dashboard_url" {
#   description = "Dashboard URL — update DNS to point to HAProxy LB IP"
#   value       = "https://rollouts.example.com"
# }

