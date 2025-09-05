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
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "4.12.1"
}

variable "storage_class" {
  description = "Storage class for Jenkins persistent volume"
  type        = string
  default     = "gp2"
}

variable "storage_size" {
  description = "Size of Jenkins persistent volume"
  type        = string
  default     = "20Gi"
}

variable "admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}