variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "admin_password" {
  description = "Argo CD admin password"
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "server_service_type" {
  description = "Service type for Argo CD server"
  type        = string
  default     = "LoadBalancer"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}