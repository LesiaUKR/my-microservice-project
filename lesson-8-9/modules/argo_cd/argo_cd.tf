# Створення namespace для Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

# Argo CD Helm Release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt(var.admin_password)
  }

  set {
    name  = "server.service.type"
    value = var.server_service_type
  }

  depends_on = [kubernetes_namespace.argocd]

  timeout = 600
}