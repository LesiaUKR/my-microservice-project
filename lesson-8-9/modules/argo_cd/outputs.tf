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