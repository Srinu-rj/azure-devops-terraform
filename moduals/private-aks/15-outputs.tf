output "haproxy_namespace" {
  value = kubernetes_namespace_v1.ha_proxy_namespace.metadata[0].name
}

output "keda_namespace" {
  value = kubernetes_namespace_v1.keda_namespace.metadata[0].name
}

output "argocd_namespace" {
  value = kubernetes_namespace_v1.argocd_namespace.metadata[0].name
}

output "nginx_namespace" {
  value = kubernetes_namespace_v1.nginx_controller.metadata[0].name
}