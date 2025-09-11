# Standard RDS Instance
resource "aws_db_instance" "standard" {
  count                   = var.use_aurora ? 0 : 1
  identifier              = var.name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.allocated_storage * 2 # Auto-scaling up to 2x
  
  # Database configuration
  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.db_port
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible
  
  # High availability and backup
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Snapshots
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  delete_automated_backups  = true
  
  # Parameter group
  parameter_group_name = aws_db_parameter_group.standard[0].name
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring[0].arn
  
  # Performance insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  # Encryption
  storage_encrypted = true
  
  tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      Type        = "standard-rds"
    }
  )
}

# Parameter group for standard RDS
resource "aws_db_parameter_group" "standard" {
  count       = var.use_aurora ? 0 : 1
  name        = "${var.name}-rds-params"
  family      = var.parameter_group_family_rds
  description = "Parameter group for ${var.name} standard RDS"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-rds-params"
      Environment = var.environment
    }
  )
}

# IAM role for RDS monitoring
resource "aws_iam_role" "rds_monitoring" {
  count = var.use_aurora ? 0 : 1
  name  = "${var.name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-rds-monitoring-role"
      Environment = var.environment
    }
  )
}

# Attach policy to monitoring role
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.use_aurora ? 0 : 1
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}