variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  default     = "admin123"
}

variable "storage_class" {
  description = "Storage class for Jenkins PVC"
  type        = string
  default     = "gp2"
}

variable "storage_size" {
  description = "Storage size for Jenkins PVC"
  type        = string
  default     = "50Gi"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for ECR access"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for ECR access"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}