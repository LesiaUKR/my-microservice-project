# Загальні налаштування
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "final-devops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# VPC налаштування
variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

# EKS налаштування
variable "eks_cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "eks_instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "eks_max_capacity" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "eks_min_capacity" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

# RDS налаштування
variable "use_aurora" {
  description = "Use Aurora cluster instead of RDS instance"
  type        = bool
  default     = false
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance"
  type        = number
  default     = 20
}

variable "aurora_engine" {
  description = "Aurora engine type"
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.r5.large"
}

variable "aurora_instances_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

# Database credentials
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "myproject"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "postgres123"
}

# Jenkins налаштування
variable "jenkins_admin_user" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
  default     = "admin123"
}

# AWS credentials для Jenkins
variable "aws_access_key_id" {
  description = "AWS Access Key ID for Jenkins ECR access"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for Jenkins ECR access"
  type        = string
  sensitive   = true
}

# Argo CD налаштування
variable "argocd_admin_password" {
  description = "Argo CD admin password"
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "git_repo_url" {
  description = "Git repository URL for Django application"
  type        = string
  default     = "https://github.com/LesiaUKR/my-microservice-project.git"
}

# Monitoring налаштування
variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin123"
}