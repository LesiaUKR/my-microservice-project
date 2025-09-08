
# RDS Terraform Module

Universal Terraform module for creating Amazon RDS databases. Supports both standard RDS instances and Aurora clusters through a single `use_aurora` flag.

## Navigation

[Back to Main Project](https://github.com/LesiaUKR/my-microservice-project/tree/main) - Main project overview and navigation to all lessons

## Features

- **Universal Design**: Switch between RDS and Aurora with one variable
- **Security**: Automatic Security Group and DB Subnet Group creation
- **Monitoring**: Enhanced Monitoring and Performance Insights enabled
- **Customizable**: Configurable parameters, backup policies, and scaling
- **Production Ready**: Encryption, monitoring, and proper IAM roles

## Quick Start

### Standard RDS Instance

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "my-app-db"
  use_aurora = false

  db_name  = "myapp"
  username = "postgres"
  password = "secure-password-123"

  vpc_id             = "vpc-12345678"
  subnet_private_ids = ["subnet-12345678", "subnet-87654321"]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Aurora Cluster

```hcl
module "rds_aurora" {
  source = "./modules/rds"

  name       = "my-app-aurora"
  use_aurora = true

  db_name  = "myapp"
  username = "postgres"
  password = "secure-password-123"

  aurora_replica_count = 2
  instance_class       = "db.r6g.large"

  vpc_id             = "vpc-12345678"
  subnet_private_ids = ["subnet-12345678", "subnet-87654321"]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Key Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `use_aurora` | bool | Create Aurora cluster instead of RDS | `false` |
| `name` | string | Database identifier | Required |
| `db_name` | string | Database name | Required |
| `username` | string | Master username | `postgres` |
| `password` | string | Master password | Required |
| `vpc_id` | string | VPC ID | Required |
| `subnet_private_ids` | list(string) | Private subnet IDs | Required |
| `instance_class` | string | Instance class | `db.t3.micro` |
| `engine` | string | Database engine (RDS) | `postgres` |
| `engine_cluster` | string | Database engine (Aurora) | `aurora-postgresql` |
| `multi_az` | bool | Multi-AZ deployment (RDS only) | `false` |
| `aurora_replica_count` | number | Aurora read replicas | `1` |
| `backup_retention_period` | number | Backup retention days | `7` |

## Outputs

| Output | Description |
|--------|-------------|
| `rds_endpoint` | Database connection endpoint |
| `rds_port` | Database port |
| `database_name` | Database name |
| `security_group_id` | Security group ID |
| `connection_string` | Connection string template |

## Security

The module creates:
- **Security Group**: Allows access only from specified CIDR blocks
- **DB Subnet Group**: Uses private subnets for database placement
- **Encryption**: Storage encryption enabled by default
- **IAM Roles**: Proper monitoring roles with least privilege

## Configuration Examples

### Changing Database Engine

**PostgreSQL to MySQL:**
```hcl
# For standard RDS
engine         = "mysql"
engine_version = "8.0"
parameter_group_family_rds = "mysql8.0"

# For Aurora
engine_cluster         = "aurora-mysql"
engine_version_cluster = "8.0.mysql_aurora.3.04.0"
parameter_group_family_aurora = "aurora-mysql8.0"
```

### Instance Class Selection

**Development (Low Cost):**
- `db.t3.micro` - 1 vCPU, 1 GB RAM
- `db.t3.small` - 1 vCPU, 2 GB RAM

**Production (High Performance):**
- `db.r6g.large` - 2 vCPU, 16 GB RAM
- `db.r6g.xlarge` - 4 vCPU, 32 GB RAM
- `db.r6g.2xlarge` - 8 vCPU, 64 GB RAM

**Example:**
```hcl
# Development
instance_class = "db.t3.micro"

# Production
instance_class = "db.r6g.large"
```

### Storage Configuration

```hcl
# Small application
allocated_storage = 20

# Medium application  
allocated_storage = 100

# Large application
allocated_storage = 500
```

### High Availability Setup

```hcl
# Production RDS with Multi-AZ
use_aurora = false
multi_az   = true
instance_class = "db.r6g.large"
backup_retention_period = 30

# Production Aurora with replicas
use_aurora = true
aurora_replica_count = 3
instance_class = "db.r6g.large"
backup_retention_period = 30
```

## Switching Between RDS and Aurora

Change the database type by modifying the `use_aurora` variable:

```hcl
# Standard RDS
use_aurora = false

# Aurora Cluster  
use_aurora = true
```

When switching, Terraform will destroy the old database and create a new one. Ensure you have backups before switching in production.

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Existing VPC with private subnets

## License

This module is open source and available under the MIT License.