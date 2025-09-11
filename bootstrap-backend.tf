terraform {
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

provider "aws" {
  region = "us-west-2"  # Змін на свій регіон
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
  environment = "dev"
}

output "s3_bucket_name" {
  value = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.s3_backend.dynamodb_table_name
}