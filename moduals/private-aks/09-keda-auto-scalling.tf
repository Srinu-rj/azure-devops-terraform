# resource "kubernetes_namespace_v1" "keda_namespace" {
#   metadata {
#     name = "keda"
#     labels = {
#       "managed-by" = "terraform"
#     }
#   }
# }
#
# resource "helm_release" "keda" {
#   name              = "keda"
#   repository        = "https://kedacore.github.io/charts"
#   chart             = "keda"
#   version           = "2.19.0"
#   namespace         = kubernetes_namespace_v1.keda_namespace.metadata[0].name
#   wait              = true #TODO  Terraform waits until pods ready
#   timeout           = 900  #TODO  Avoid false failure
#   atomic            = true # TODO Auto rollback if failed
#   cleanup_on_fail   = true # TODO  Prevents broken releases
#   dependency_update = true
#   create_namespace  = false
#
#   set = [
#     # ✅ FIX 1: type = "auto" — passes as integer not string
#     {
#       name  = "replicaCount"
#       value = "2"
#       type  = "auto"
#     },
#     # ✅ FIX 2: type = "auto" — passes as integer not string
#     {
#       name  = "metricsServer.replicaCount"
#       value = "2"
#       type  = "auto"
#     },
#     # ✅ FIX 3a: correct KEDA Prometheus path for metric server
#     # ❌ Wrong:  "prometheus.metricServer.enabled"
#     # ✅ Correct: "prometheus.metricServer.enabled" is under operator scope
#     {
#       name  = "prometheus.metricServer.enabled"
#       value = "true"
#       type  = "auto" # boolean needs type = "auto"
#     },
#
#     # ✅ FIX 3b: also enable operator and webhooks metrics (recommended)
#     {
#       name  = "prometheus.operator.enabled"
#       value = "true"
#       type  = "auto"
#     },
#     {
#       name  = "prometheus.webhooks.enabled"
#       value = "true"
#       type  = "auto"
#     },
#     {
#       name  = "resources.requests.cpu"
#       value = "100m"
#     },
#     {
#       name  = "resources.requests.memory"
#       value = "128Mi"
#     },
#     #TODO  4️⃣ Enable Leader Election Explicitly (Recommended for HA)
#     {
#       name  = "leaderElection.enabled"
#       value = "true"
#       type  = "auto"
#     }
#
#   ]
#   depends_on = [
#     kubernetes_namespace_v1.keda_namespace,
#     azurerm_kubernetes_cluster.aks_cluster_backend
#   ]
# }
#
#
