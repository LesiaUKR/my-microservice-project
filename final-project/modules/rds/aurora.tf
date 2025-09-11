# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  count              = var.use_aurora ? 1 : 0
  cluster_identifier = "${var.name}-cluster"
  
  # Engine configuration
  engine         = var.engine_cluster
  engine_version = var.engine_version_cluster
  
  # Database configuration
  database_name   = var.db_name
  master_username = var.username
  master_password = var.password
  port            = var.db_port
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Backup configuration
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Snapshots
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.name}-cluster-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Parameter group
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  
  # Encryption
  storage_encrypted = true
  
  # Deletion protection
  deletion_protection = false
  
  # Copy tags to snapshots
  copy_tags_to_snapshot = true
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-cluster"
      Environment = var.environment
      Type        = "aurora-cluster"
    }
  )
}

# Aurora Writer Instance
resource "aws_rds_cluster_instance" "aurora_writer" {
  count              = var.use_aurora ? 1 : 0
  identifier         = "${var.name}-writer"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = var.engine_cluster
  engine_version     = var.engine_version_cluster
  
  # Network configuration
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible = var.publicly_accessible
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.aurora_monitoring[0].arn
  
  # Performance insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-writer"
      Environment = var.environment
      Role        = "writer"
    }
  )
}

# Aurora Reader Instances
resource "aws_rds_cluster_instance" "aurora_readers" {
  count              = var.use_aurora ? var.aurora_replica_count : 0
  identifier         = "${var.name}-reader-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = var.engine_cluster
  engine_version     = var.engine_version_cluster
  
  # Network configuration
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible = var.publicly_accessible
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.aurora_monitoring[0].arn
  
  # Performance insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-reader-${count.index + 1}"
      Environment = var.environment
      Role        = "reader"
    }
  )
}

# Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora" {
  count       = var.use_aurora ? 1 : 0
  name        = "${var.name}-aurora-cluster-params"
  family      = var.parameter_group_family_aurora
  description = "Aurora cluster parameter group for ${var.name}"

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
      Name        = "${var.name}-aurora-cluster-params"
      Environment = var.environment
    }
  )
}

# IAM role for Aurora monitoring
resource "aws_iam_role" "aurora_monitoring" {
  count = var.use_aurora ? 1 : 0
  name  = "${var.name}-aurora-monitoring-role"

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
      Name        = "${var.name}-aurora-monitoring-role"
      Environment = var.environment
    }
  )
}

# Attach policy to Aurora monitoring role
resource "aws_iam_role_policy_attachment" "aurora_monitoring" {
  count      = var.use_aurora ? 1 : 0
  role       = aws_iam_role.aurora_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}