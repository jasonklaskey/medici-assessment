# Architecture Documentation - Medici Assessment

Detailed architecture and design decisions for the AWS DevOps infrastructure.

## System Architecture

AWS Region: eu-west-1 (Ireland)
Main Network: VPC 10.0.0.0/16

Public Layer:
- 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
- EC2 Instance (t3.micro)
- Docker Nginx Container
- Internet Gateway

Private Layer:
- 2 Private Subnets (10.0.10.0/24, 10.0.11.0/24)
- RDS MySQL Database (Multi-AZ)
- NAT Gateway for outbound internet

Container Registry:
- ECR Repository (medici-assessment-ecr)
- Docker Images stored and scanned

CI/CD Pipeline:
- GitHub Repository
- GitHub Actions Workflow
- Manual Approval Gate
- Automated Deployment

## Network Architecture

### VPC Design

```
VPC: 10.0.0.0/16
Public Subnet 1: 10.0.1.0/24 (eu-west-1a)
Public Subnet 2: 10.0.2.0/24 (eu-west-1b)
Private Subnet 1: 10.0.10.0/24 (eu-west-1a)
Private Subnet 2: 10.0.11.0/24 (eu-west-1b)
```

### Routing

Public Route Table:
- Destination: 0.0.0.0/0
- Target: Internet Gateway

Private Route Table:
- Destination: 0.0.0.0/0
- Target: NAT Gateway

### Security Groups

EC2 Security Group:

```
Inbound:
- HTTP (80) from 0.0.0.0/0
- HTTPS (443) from 0.0.0.0/0
- SSH (22) from 0.0.0.0/0

Outbound:
- All traffic to 0.0.0.0/0
```

RDS Security Group:

```
Inbound:
- MySQL (3306) from EC2 SG only

Outbound:
- All traffic to 0.0.0.0/0
```

## Compute Architecture

### EC2 Instance

- Instance Type: t3.micro
- AMI: Amazon Linux 2
- Availability Zone: eu-west-1a
- Public IP: 34.255.179.146
- Private IP: 10.0.1.80
- Root Volume: 8 GB gp2

### Docker Container

- Image: nginx:latest
- Container Name: nginx-server
- Port Mapping: 0.0.0.0:80 -> 80/tcp

## Database Architecture

### RDS MySQL

- Engine: MySQL 8.0
- Instance Class: db.t3.micro
- Storage: 20 GB gp2
- Multi-AZ: Enabled
- Backup Retention: 7 days
- Database: devopsdb

## Container Registry Architecture

### ECR Repository

- Repository Name: medici-assessment-ecr
- Registry ID: 205883165886
- Region: eu-west-1
- Image Scanning: Enabled on push

## CI/CD Pipeline Architecture

### GitHub Actions Workflow

Trigger Events:
- Push to main branch
- Manual trigger via workflow_dispatch

Pipeline Stages:

1. Build Stage
   - Checkout code
   - Configure AWS credentials
   - Login to ECR
   - Build Docker image
   - Push to ECR

2. Manual Approval Stage
   - Environment: medici-assessment
   - Requires: Manual approval

3. Deploy Stage
   - SSH into EC2
   - Pull image from ECR
   - Stop old container
   - Start new container

## Infrastructure as Code

### Terraform Structure

```
terraform/
├── environments/
│   └── dev/
│       ├── vpc/
│       ├── security-groups/
│       ├── ec2/
│       ├── rds/
│       └── ecr/
└── terragrunt.hcl
```

## Security Architecture

- VPC Isolation: Private subnets for database
- Security Groups: Least privilege access
- Secrets Management: AWS Secrets Manager
- RDS Encryption: Enabled (KMS)
- Backup Encryption: Enabled

## Cost Analysis

EC2 t3.micro: $0 (free tier)
RDS db.t3.micro: $0 (free tier)
NAT Gateway: $32.00
Data Transfer Out: $0.02/GB
ECR Storage: $0.10/GB
Total: $35-50

## Scalability

### Horizontal Scaling
- Add more EC2 instances
- Use Application Load Balancer
- Implement auto-scaling groups

### Vertical Scaling
- Increase EC2 instance type
- Increase RDS instance class

### Database Scaling
- Read replicas for read-heavy workloads
- Sharding for large datasets

## High Availability

### Current Setup
- Multi-AZ RDS (automatic failover)
- Single EC2 instance (no redundancy)

### Future Improvements
- Multiple EC2 instances with load balancer
- RDS read replicas
- Auto-scaling groups
- CloudFront CDN

## Performance

### Expected Performance
- Web Server Response Time: < 100ms
- RDS Query Latency: < 10ms
- Docker Image Build Time: 2-3 minutes
- Deployment Time: 5-10 minutes

## Component Interactions

GitHub -> GitHub Actions -> ECR -> EC2 + RDS

```
1. Developer pushes code to GitHub
2. GitHub Actions workflow triggers
3. Docker image is built
4. Image is pushed to ECR
5. Manual approval is required
6. Image is deployed to EC2
7. EC2 pulls image from ECR
8. Old container is stopped
9. New container is started
10. Web server serves updated content
```

## Design Decisions

### Why Terraform + Terragrunt?
- Infrastructure as Code
- Version control for infrastructure
- Reproducible deployments
- Easy rollbacks

### Why Docker?
- Lightweight and portable
- Consistent across environments
- Easy scaling

### Why GitHub Actions?
- Native GitHub integration
- No additional tools needed
- Free for public repositories

### Why Multi-AZ RDS?
- High availability
- Automatic failover
- Better reliability

## Architecture Goals

✅ High Availability
✅ Security
✅ Scalability
✅ Cost Optimization
✅ Automation
✅ Disaster Recovery
✅ Monitoring
✅ Documentation
