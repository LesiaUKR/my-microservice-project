# Kubernetes 
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

# AWS credentials secret
resource "kubernetes_secret" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = var.namespace
  }

  data = {
    aws-access-key-id     = var.aws_access_key_id
    aws-secret-access-key = var.aws_secret_access_key
    region                = var.aws_region
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.jenkins]
}

# Jenkins Helm Release
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "4.8.3"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  timeout = 1200  
  wait    = true  

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.admin.username"
    value = var.jenkins_admin_user
  }

  set {
    name  = "controller.admin.password"
    value = var.jenkins_admin_password
  }

  set {
    name  = "persistence.storageClass"
    value = var.storage_class
  }

  set {
    name  = "persistence.size"
    value = var.storage_size
  }

  depends_on = [kubernetes_namespace.jenkins, kubernetes_secret.aws_credentials]
}

# Service Account для Jenkins з правами до EKS
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins-admin"
    namespace = var.namespace
  }
  
  depends_on = [kubernetes_namespace.jenkins]
}

# ClusterRoleBinding для Jenkins
resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-admin"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = var.namespace
  }
}