output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = var.namespace
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}

# Data source для отримання LoadBalancer hostname
data "kubernetes_service" "grafana" {
  metadata {
    name      = "prometheus-grafana"
    namespace = var.namespace
  }
  
  depends_on = [helm_release.prometheus]
}

output "grafana_external_url" {
  description = "External URL to access Grafana"
  value       = length(data.kubernetes_service.grafana.status[0].load_balancer) > 0 && length(data.kubernetes_service.grafana.status[0].load_balancer[0].ingress) > 0 ? "http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}" : "LoadBalancer pending..."
}

data "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus-kube-prometheus-prometheus"
    namespace = var.namespace
  }
  
  depends_on = [helm_release.prometheus]
}

output "prometheus_url" {
  description = "Prometheus server URL"
  value       = "prometheus-kube-prometheus-prometheus.${var.namespace}.svc.cluster.local:9090"
}