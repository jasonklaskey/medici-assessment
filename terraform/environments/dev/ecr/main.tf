terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

# ECR Lifecycle Policy - Keep only last 10 images
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ECR Repository ARN"
  value       = aws_ecr_repository.main.arn
}

output "ecr_registry_id" {
  description = "ECR Registry ID"
  value       = aws_ecr_repository.main.registry_id
}
