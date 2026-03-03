# resource "kubernetes_namespace_v1" "cert_manager_namespace" {
#   metadata {
#     name = "cert-manager"
#
#     labels = {
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }
# }
#
# resource "helm_release" "cert_manager" {
#   name              = "cert-manager"
#   repository        = "https://charts.jetstack.io"
#   chart             = "cert-manager"
#   version           = "v1.14.4" # pin to a specific version
#   namespace         = kubernetes_namespace_v1.cert_manager_namespace.metadata[0].name
#   wait              = true
#   timeout           = 1800
#   atomic            = true
#   cleanup_on_fail   = true
#   dependency_update = true
#
#   # Required: installs the CRDs (CertificateRequests, Issuers, etc.)
#   set = [
#     {
#       name  = "installCRDs"
#       value = "true"
#     },
#     # Optional but recommended
#     # ✅ Leader election namespace
#     {
#       name  = "global.leaderElection.namespace"
#       value = "cert-manager"
#     },
#     # ✅ Install CRDs — Certificate, ClusterIssuer, etc.
#     {
#       name  = "installCRDs"
#       value = "true"
#       type  = "auto" # ✅ boolean
#     },
#     {
#       name  = "webhook.replicaCount"
#       value = "2"
#       type  = "auto" # ✅ integer
#     },
#     {
#       name  = "cainjector.replicaCount"
#       value = "2"
#       type  = "auto" # ✅ integer
#     },
#     {
#       name  = "replicaCount"
#       value = "2"
#       type  = "auto"                         # ✅ integer
#     }
#   ]
#   depends_on = [
#     kubernetes_namespace_v1.cert_manager_namespace,
#     azurerm_kubernetes_cluster.aks_cluster_backend
#   ]
# }

# output "cert_manager_namespace" {
#   description = "Namespace where cert-manager is installed"
#   value       = kubernetes_namespace_v1.cert_manager_namespace.metadata[0].name
# }
#
# output "letsencrypt_staging_issuer" {
#   description = "Staging ClusterIssuer name — use in Ingress annotations"
#   value       = "letsencrypt-staging"
# }
#
# output "letsencrypt_prod_issuer" {
#   description = "Production ClusterIssuer name — use after staging is verified"
#   value       = "letsencrypt-prod"
# }
