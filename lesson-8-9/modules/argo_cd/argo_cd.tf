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

# Helm release для створення Argo CD Applications
resource "helm_release" "argocd_applications" {
  name       = "argocd-applications"
  chart      = "${path.module}/charts"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "gitRepoUrl"
    value = var.git_repo_url
  }

  set {
    name  = "targetRevision"
    value = var.target_revision
  }

  set {
    name  = "djangoAppNamespace"
    value = var.django_app_namespace
  }

  depends_on = [helm_release.argocd]

  timeout = 300
}