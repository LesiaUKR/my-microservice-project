output "argocd_server_url" {
  description = "URL to access Argo CD server"
  value       = "argocd-server.${var.namespace}.svc.cluster.local"
}

output "argocd_namespace" {
  description = "Argo CD namespace"
  value       = var.namespace
}

output "argocd_admin_password" {
  description = "Argo CD admin password"
  value       = var.admin_password
  sensitive   = true
}

# Додаткові outputs для LoadBalancer
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }
  
  depends_on = [helm_release.argocd]
}

output "argocd_external_url" {
  description = "External URL to access Argo CD server (LoadBalancer)"
  value       = length(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress) > 0 ? "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}" : "LoadBalancer pending..."
}