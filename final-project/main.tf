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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
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
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}

# Generate random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Backend Module
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "final-devops-terraform-state-${random_id.bucket_suffix.hex}"
  table_name  = "terraform-locks"
  environment = var.environment
}

# VPC Module
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = "${var.project_name}-vpc"
  environment        = var.environment
}

# ECR Module
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "${var.project_name}-django-ecr"
  scan_on_push = true
  environment  = var.environment
}

# EKS Module  
module "eks" {
  source = "./modules/eks"
  
  cluster_name     = "${var.project_name}-eks-cluster"
  cluster_version  = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  node_group_name = "worker-nodes"
  instance_types  = var.eks_instance_types
  desired_capacity = var.eks_desired_capacity
  max_capacity    = var.eks_max_capacity
  min_capacity    = var.eks_min_capacity
  environment     = var.environment
}

# Jenkins Module
module "jenkins" {
  source = "./modules/jenkins"
  
  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  namespace        = "jenkins"
  
  jenkins_admin_user     = var.jenkins_admin_user
  jenkins_admin_password = var.jenkins_admin_password
  
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region           = var.aws_region
  
  storage_class = "gp2"
  storage_size  = "50Gi"
  
  depends_on = [module.eks]
}

# Argo CD Module
module "argo_cd" {
  source = "./modules/argo-cd"
  
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  
  namespace           = "argocd"
  admin_password      = var.argocd_admin_password
  server_service_type = "LoadBalancer"
  environment         = var.environment
  
  # Git repository settings
  git_repo_url           = var.git_repo_url
  target_revision        = "final-project"
  django_app_namespace   = "django-app"
  
  depends_on = [module.eks]
}


# RDS Database Module
module "rds" {
  source = "./modules/rds"

  # Basic configuration
  name        = "django-app-db"
  use_aurora  = false
  environment = var.environment

  # Database configuration
  db_name  = "django_app"
  username = "postgres"
  password = var.db_password

  # Engine configuration (для стандартної RDS)
  engine         = "postgres"
  engine_version = "15.7"
  
  # Engine configuration
  engine_cluster         = "aurora-postgresql"
  engine_version_cluster = "15.4"

  # Instance configuration
  instance_class    = "db.t3.micro"
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
  multi_az                = false
  backup_retention_period = 7
  aurora_replica_count    = 1

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

module "monitoring" {
  source = "./modules/monitoring"
  
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  namespace                          = "monitoring"
  grafana_admin_password             = var.grafana_admin_password
  environment                        = var.environment
  
  depends_on = [module.eks]
}