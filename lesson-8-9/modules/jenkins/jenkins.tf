# Створення namespace для Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# Jenkins Helm Release
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.admin.username"
    value = var.admin_user
  }

  set_sensitive {
    name  = "controller.admin.password"
    value = var.admin_password
  }

  set {
    name  = "persistence.storageClass"
    value = var.storage_class
  }

  set {
    name  = "persistence.size"
    value = var.storage_size
  }

  depends_on = [kubernetes_namespace.jenkins]

  timeout = 600
}

# Service Account для Jenkins з правами
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins-sa"
    namespace = var.namespace
  }

  depends_on = [kubernetes_namespace.jenkins]
}

# ClusterRole для Jenkins
resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "pods/log", "persistentvolumeclaims"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["*"]
  }
}

# ClusterRoleBinding для Jenkins
resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = var.namespace
  }
}