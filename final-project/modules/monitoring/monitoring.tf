# Kubernetes namespace для monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Prometheus Helm Release
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/prometheus-values.yaml")
  ]

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name  = "grafana.service.type"
    value = var.grafana_service_type
  }

  depends_on = [kubernetes_namespace.monitoring]

  timeout = 900
}

# Додаткові налаштування для Grafana
# resource "kubernetes_config_map" "grafana_dashboards" {
#   metadata {
#     name      = "custom-dashboards"
#     namespace = var.namespace
#     labels = {
#       grafana_dashboard = "1"
#     }
#   }
# 
#   data = {
#     "django-dashboard.json" = file("${path.module}/dashboards/django-dashboard.json")
#   }
# 
#   depends_on = [helm_release.prometheus]
# }