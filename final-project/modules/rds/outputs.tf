# Database endpoints
output "rds_endpoint" {
  description = "RDS instance endpoint (writer endpoint for Aurora)"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "rds_reader_endpoint" {
  description = "RDS reader endpoint (Aurora only)"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

# Database connection details
output "rds_port" {
  description = "RDS instance port"
  value       = var.db_port
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "username" {
  description = "Database master username"
  value       = var.username
}

# Network details
output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.default.name
}

# Resource identifiers
output "rds_identifier" {
  description = "RDS instance identifier"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].cluster_identifier : aws_db_instance.standard[0].id
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].arn : aws_db_instance.standard[0].arn
}

output "rds_resource_id" {
  description = "RDS instance resource ID"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].cluster_resource_id : aws_db_instance.standard[0].resource_id
}

# Aurora specific outputs
output "aurora_cluster_members" {
  description = "List of Aurora cluster members"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].cluster_members : []
}

output "aurora_writer_instance_id" {
  description = "Aurora writer instance identifier"
  value       = var.use_aurora ? aws_rds_cluster_instance.aurora_writer[0].id : null
}

output "aurora_reader_instance_ids" {
  description = "List of Aurora reader instance identifiers"
  value       = var.use_aurora ? aws_rds_cluster_instance.aurora_readers[*].id : []
}

# Connection string for applications
output "connection_string" {
  description = "Database connection string template"
  value = format("postgresql://%s:<password>@%s:%s/%s",
    var.username,
    var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint,
    var.db_port,
    var.db_name
  )
  sensitive = false
}

# Database type for reference
output "database_type" {
  description = "Type of database created (aurora or standard)"
  value       = var.use_aurora ? "aurora" : "standard"
}

output "engine" {
  description = "Database engine"
  value       = var.use_aurora ? var.engine_cluster : var.engine
}

output "engine_version" {
  description = "Database engine version"
  value       = var.use_aurora ? var.engine_version_cluster : var.engine_version
}