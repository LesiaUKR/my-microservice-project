variable "name" {
  description = "Name of the RDS instance or Aurora cluster"
  type        = string
}

variable "use_aurora" {
  description = "Whether to create Aurora cluster (true) or standard RDS instance (false)"
  type        = bool
  default     = false
}

# Engine configuration
variable "engine" {
  description = "Database engine for standard RDS"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Engine must be either 'postgres' or 'mysql'."
  }
}

variable "engine_cluster" {
  description = "Database engine for Aurora cluster"
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = contains(["aurora-postgresql", "aurora-mysql"], var.engine_cluster)
    error_message = "Aurora engine must be either 'aurora-postgresql' or 'aurora-mysql'."
  }
}

variable "engine_version" {
  description = "Engine version for standard RDS"
  type        = string
  default     = "15.7"
}

variable "engine_version_cluster" {
  description = "Engine version for Aurora cluster"
  type        = string
  default     = "15.7"
}

# Instance configuration
variable "instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (only for standard RDS)"
  type        = number
  default     = 20
}

# Database configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "postgres"
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

# Network configuration
variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "subnet_private_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the database should be publicly accessible"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# High availability and backup
variable "multi_az" {
  description = "Enable Multi-AZ deployment (only for standard RDS)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

# Aurora specific
variable "aurora_replica_count" {
  description = "Number of Aurora read replicas"
  type        = number
  default     = 1
}

# Parameter groups
variable "parameter_group_family_rds" {
  description = "Parameter group family for standard RDS"
  type        = string
  default     = "postgres15"
}

variable "parameter_group_family_aurora" {
  description = "Parameter group family for Aurora"
  type        = string
  default     = "aurora-postgresql15"
}

variable "parameters" {
  description = "Database parameters to apply"
  type        = map(string)
  default = {
    "max_connections"        = "100"
    "shared_preload_libraries" = "pg_stat_statements"
    "log_statement"          = "all"
    "log_min_duration_statement" = "1000"
  }
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}