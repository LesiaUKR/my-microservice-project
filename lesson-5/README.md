# Terraform Infrastructure as Code (IaC)

AWS infrastructure deployment using Terraform with modular architecture, remote state management, and best practices.

## Navigation

- [Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## Project Overview

This project demonstrates Infrastructure as Code (IaC) principles using Terraform to deploy AWS infrastructure with:

- **S3 Backend** - Remote state storage with versioning and encryption
- **DynamoDB** - State locking mechanism for team collaboration
- **VPC Network** - Multi-AZ architecture with public and private subnets
- **ECR Repository** - Container registry for Docker images

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Account                           │
├─────────────────────────────────────────────────────────────────┤
│  S3 Bucket              DynamoDB Table        ECR Repository    │
│  (State Storage)        (State Locking)       (Container Reg)   │
├─────────────────────────────────────────────────────────────────┤
│                        VPC (10.0.0.0/16)                        │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Public Subnets (3)          Private Subnets (3)           │ │
│  │  ┌─────────────┐              ┌─────────────┐              │ │
│  │  │ 10.0.1.0/24 │              │ 10.0.4.0/24 │              │ │
│  │  │ 10.0.2.0/24 │              │ 10.0.5.0/24 │              │ │
│  │  │ 10.0.3.0/24 │              │ 10.0.6.0/24 │              │ │
│  │  └─────────────┘              └─────────────┘              │ │
│  │         │                            │                     │ │
│  │   Internet Gateway              NAT Gateways               │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
lesson-5/
├── main.tf                     # Main Terraform configuration
├── backend.tf                  # S3 backend configuration  
├── outputs.tf                  # Root module outputs
├── .gitignore                  # Terraform-specific ignores
├── README.md                   # Project documentation
│
└── modules/                    # Reusable Terraform modules
    ├── s3-backend/             # S3 + DynamoDB for remote state
    │   ├── s3.tf              # S3 bucket configuration
    │   ├── dynamodb.tf        # DynamoDB table for locking
    │   ├── variables.tf       # Input variables
    │   └── outputs.tf         # Module outputs
    │
    ├── vpc/                    # VPC networking module
    │   ├── vpc.tf             # VPC, subnets, gateways
    │   ├── routes.tf          # Route tables and associations
    │   ├── variables.tf       # Input variables
    │   └── outputs.tf         # Module outputs
    │
    └── ecr/                    # ECR repository module
        ├── ecr.tf             # ECR repository configuration
        ├── variables.tf       # Input variables
        └── outputs.tf         # Module outputs
```

## Features

### S3 Backend Module
- **Secure Storage**: S3 bucket with encryption and versioning
- **Access Control**: Bucket policies and public access blocking
- **State Locking**: DynamoDB table for concurrent access protection

### VPC Module  
- **Multi-AZ Architecture**: 3 availability zones for high availability
- **Network Segmentation**: Public and private subnets separation
- **Internet Access**: Internet Gateway for public resources
- **NAT Gateways**: Outbound internet access for private resources
- **Route Tables**: Proper traffic routing configuration

### ECR Module
- **Container Registry**: AWS Elastic Container Registry
- **Security Scanning**: Automatic vulnerability scanning on push
- **Lifecycle Policies**: Automatic image cleanup and retention
- **Access Policies**: Fine-grained repository permissions

## Prerequisites

- **Terraform** >= 1.0 installed
- **AWS CLI** configured with appropriate credentials
- **AWS Account** with sufficient permissions for:
  - S3 bucket creation and management
  - DynamoDB table operations
  - VPC and networking resources
  - ECR repository management

## Deployment Instructions

### Phase 1: Initial Deployment (Local State)

1. **Initialize Terraform:**
```bash
terraform init
```

2. **Review the execution plan:**
```bash
terraform plan
```

3. **Deploy infrastructure:**
```bash
terraform apply
```

4. **Note the outputs** - especially the S3 bucket name for backend configuration.

### Phase 2: Migrate to Remote State

1. **Update backend.tf** with the created S3 bucket name:
```hcl
terraform {
  backend "s3" {
    bucket         = "lesson5-terraform-state-<your-suffix>"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

2. **Reinitialize with backend:**
```bash
terraform init -migrate-state
```

3. **Verify remote state:**
```bash
terraform plan
```

## Module Usage

### S3 Backend Module
```hcl
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-terraform-state-bucket"
  table_name  = "terraform-locks"
  environment = "dev"
}
```

### VPC Module
```hcl
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "my-vpc"
}
```

### ECR Module
```hcl
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "my-app-repository"
  scan_on_push = true
  environment = "dev"
}
```

## Management Commands

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Destroy infrastructure (⚠️ Use with caution)
terraform destroy
```

## Cost Optimization

- **S3 Bucket**: Minimal cost for state storage
- **DynamoDB**: Pay-per-request billing mode
- **VPC Components**: Most networking components are free
- **NAT Gateways**: Main cost component (~$45/month per gateway)
- **ECR**: First 500MB of storage per month is free

## Security Best Practices

- S3 bucket encryption enabled
- Public access blocked on S3 bucket
- VPC with private subnets for sensitive resources
- ECR vulnerability scanning enabled
- Least privilege access policies

## Troubleshooting

### Common Issues

1. **Backend initialization fails**: Ensure S3 bucket exists and you have permissions
2. **State locking errors**: Check DynamoDB table exists and is accessible
3. **Resource creation fails**: Verify AWS credentials and permissions
4. **Subnet CIDR conflicts**: Ensure subnet CIDR blocks don't overlap

### Useful Commands

```bash
# Force unlock state (if locked)
terraform force-unlock <lock-id>

# Import existing resources
terraform import <resource_type>.<name> <resource_id>

# Refresh state
terraform refresh
```
