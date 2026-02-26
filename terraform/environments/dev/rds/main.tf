terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terragrunt"
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "private_subnet_1_id" {
  description = "Private Subnet 1 ID"
  type        = string
}

variable "private_subnet_2_id" {
  description = "Private Subnet 2 ID"
  type        = string
}

variable "rds_security_group_id" {
  description = "RDS Security Group ID"
  type        = string
}

# Generate random password - RDS safe (no /, @, ", space)
resource "random_password" "db_password" {
  length      = 16
  special     = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Generate random suffix for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Secrets Manager Secret with unique name
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}-db-password-${random_string.suffix.result}"
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-db-password"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
    host     = aws_db_instance.main.address
    port     = 3306
    dbname   = "devopsdb"
  })
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-mysql-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "devopsdb"
  username = "admin"
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "${var.project_name}-mysql-db"
  }

  depends_on = [aws_db_subnet_group.main]
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS Address"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS Database Name"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "RDS Username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_password_secret_arn" {
  description = "Secrets Manager Secret ARN"
  value       = aws_secretsmanager_secret.db_password.arn
}
