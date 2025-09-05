terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Variables for main.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Generate random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Backend Module
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "lesson9-terraform-state-${random_id.bucket_suffix.hex}"
  table_name  = "terraform-locks"
  environment = var.environment
}

# VPC Module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-9-vpc"
  environment        = var.environment
}

# ECR Module
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-9-django-ecr"
  scan_on_push = true
  environment  = var.environment
}

# EKS Module  
module "eks" {
  source = "./modules/eks"
  
  cluster_name     = "lesson-9-eks-cluster"
  cluster_version  = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  node_group_name = "worker-nodes"
  instance_types  = ["t3.medium"]
  desired_capacity = 2
  max_capacity    = 4
  min_capacity    = 1
  environment     = var.environment
}

# Jenkins Module (без depends_on)
# module "jenkins" {
#   source = "./modules/jenkins"
#   
#   cluster_name                       = module.eks.cluster_name
#   cluster_endpoint                   = module.eks.cluster_endpoint
#   cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#   
#   namespace    = "jenkins"
#   environment  = var.environment
# }

# Argo CD Module
module "argocd" {
  source = "./modules/argo_cd"
  
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  
  namespace    = "argocd"
  environment  = var.environment
}