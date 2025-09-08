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

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Variables for main.tf
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

# Jenkins Module
module "jenkins" {
  source = "./modules/jenkins"
  
  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  namespace        = "jenkins"
  
  jenkins_admin_user     = "admin"
  jenkins_admin_password = "your-secure-password-123"
  
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region           = var.aws_region
  
  storage_class = "gp2"
  storage_size  = "50Gi"
  
  depends_on = [module.eks]
}

# Argo CD Module
module "argocd" {
  source = "./modules/argo_cd"
  
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  
  namespace           = "argocd"
  admin_password      = "argocd-admin-123"
  server_service_type = "LoadBalancer"
  environment         = var.environment
  
  # Git repository settings
  git_repo_url           = "https://github.com/LesiaUKR/my-microservice-project.git"
  target_revision        = "lesson-7"
  django_app_namespace   = "django-app"
  
  depends_on = [module.eks]
}

# RDS Database Module
module "rds" {
  source = "./modules/rds"

  # Basic configuration
  name        = "django-app-db"
  use_aurora  = false  # Змініть на true для Aurora
  environment = var.environment

  # Database configuration
  db_name  = "django_app"
  username = "postgres"
  password = var.db_password  # Додайте цю змінну

  # Engine configuration (для стандартної RDS)
  engine         = "postgres"
  engine_version = "15.7"
  
  # Engine configuration (для Aurora - використовується якщо use_aurora = true)
  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.4"

  # Instance configuration
  instance_class    = "db.t3.micro"  # Для продакшену використовуйте більший клас
  allocated_storage = 20

  # Network configuration
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnet_ids
  subnet_public_ids   = module.vpc.public_subnet_ids
  publicly_accessible = false
  
  # Security
  allowed_cidr_blocks = [module.vpc.vpc_cidr_block]
   # eks_security_group_ids = [module.eks.cluster_security_group_id]

  # High availability
  multi_az                = false  # true для продакшену
  backup_retention_period = 7
  aurora_replica_count    = 1      # Тільки для Aurora

  # Database parameters
  parameters = {
    "max_connections"              = "100"
    "shared_preload_libraries"     = "pg_stat_statements"
    "log_statement"                = "all"
    "log_min_duration_statement"   = "1000"
    "work_mem"                     = "4096"
  }

  # Parameter group families
  parameter_group_family_rds    = "postgres15"
  parameter_group_family_aurora = "aurora-postgresql15"

  # Tags
  tags = {
    Name        = "django-app-database"
    Environment = var.environment
    Project     = "django-microservice"
    ManagedBy   = "terraform"
  }

  depends_on = [module.vpc]
}

