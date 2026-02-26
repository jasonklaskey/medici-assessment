# Medici Assessment - AWS DevOps Infrastructure

A complete, production-ready AWS DevOps infrastructure with automated CI/CD pipeline, containerization, and infrastructure-as-code.

## 🎯 Project Overview

This project demonstrates a fully automated DevOps pipeline that:
- Provisions AWS infrastructure using Terraform & Terragrunt
- Builds Docker images via GitHub Actions
- Pushes images to Amazon ECR
- Deploys to EC2 with manual approval gates
- Manages databases with RDS MySQL
- Implements security best practices

## 🚀 Quick Start

### Prerequisites
- AWS Account with appropriate permissions
- Terraform & Terragrunt installed
- Docker installed
- GitHub account
- AWS CLI configured

### Deployment

```bash
git clone https://github.com/jasonklaskey/medici-assessment.git
cd medici-assessment
./deploy-all.sh
```

## 📋 Infrastructure Components

### VPC & Networking
- VPC CIDR: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24 (2 AZs)
- Private Subnets: 10.0.10.0/24, 10.0.11.0/24 (2 AZs)

### Compute
- EC2 Instance: t3.micro (Amazon Linux 2)
- Docker: Nginx web server

### Database
- RDS MySQL: db.t3.micro
- Multi-AZ: Enabled
- Database: devopsdb

### Container Registry
- ECR Repository: medici-assessment-ecr

## 🔐 Security

- VPC Isolation
- Security Groups with least privilege
- Secrets Management
- Encryption enabled

## 💰 Cost

Estimated Monthly Cost: $35-50

## 📚 Documentation

- TESTING_GUIDE.md
- ARCHITECTURE.md
- DEPLOYMENT_GUIDE.md
- CTO_PRESENTATION.md

## 👤 Author

Jason Laskey

## 🔗 Links

- GitHub: https://github.com/jasonklaskey/medici-assessment
- Web Server: http://34.255.179.146
