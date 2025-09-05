output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://jenkins.${var.namespace}.svc.cluster.local:8080"
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = var.admin_user
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = var.admin_password
  sensitive   = true
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value       = var.namespace
}

output "jenkins_service_account" {
  description = "Jenkins service account name"
  value       = kubernetes_service_account.jenkins.metadata[0].name
}