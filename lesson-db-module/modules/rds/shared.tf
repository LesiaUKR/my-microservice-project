# DB Subnet Group (used by both Aurora and standard RDS)
resource "aws_db_subnet_group" "default" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-subnet-group"
      Environment = var.environment
    }
  )
}

# Security Group for RDS (used by both Aurora and standard RDS)
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    description = "Database access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-rds-sg"
      Environment = var.environment
    }
  )
}

# Security Group rule for EKS access (if needed)
resource "aws_security_group_rule" "eks_to_rds" {
  count                    = length(var.eks_security_group_ids)
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = var.eks_security_group_ids[count.index]
  security_group_id        = aws_security_group.rds.id
  description              = "Allow EKS cluster access to RDS"
}

# Additional variable for EKS integration
variable "eks_security_group_ids" {
  description = "List of EKS security group IDs that should have access to RDS"
  type        = list(string)
  default     = []
}