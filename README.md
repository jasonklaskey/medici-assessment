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
./infrastructure.sh
```

The script will:
1. Show you the Terraform plan
2. Ask if you want to deploy
3. Deploy all infrastructure
4. Ask if you want to destroy (optional)

## 📋 Infrastructure Components

### VPC & Networking
- VPC CIDR: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24 (2 AZs)
- Private Subnets: 10.0.10.0/24, 10.0.11.0/24 (2 AZs)
- Internet Gateway: For public subnet internet access
- NAT Gateway: For private subnet outbound internet access

### Compute
- EC2 Instance: t3.micro (Amazon Linux 2)
- Docker: Nginx web server
- Security Group: Allows HTTP (80), HTTPS (443), SSH (22)

### Database
- RDS MySQL: db.t3.micro
- Multi-AZ: Yes (High Availability)
- Database: devopsdb
- Backup Retention: 7 days
- Security Group: Only allows MySQL (3306) from EC2

### Container Registry
- ECR Repository: medici-assessment-ecr
- Image Scanning: Enabled on push
- Lifecycle Policy: Keep last 10 images

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

1. Trigger: Push to main branch or manual trigger
2. Build Stage:
   - Checkout code
   - Configure AWS credentials
   - Login to ECR
   - Build Docker image
   - Push to ECR

3. Manual Approval: Workflow pauses for approval

4. Deploy Stage:
   - Configure AWS credentials
   - SSH into EC2
   - Login to ECR
   - Pull latest image
   - Stop old container
   - Start new container

### Workflow File
- Location: .github/workflows/deploy.yml
- Environment: medici-assessment (requires approval)

## 🧪 Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing procedures.

### Quick Tests

```bash
# Test web server
curl http://34.255.179.146

# SSH into EC2
ssh -i medici-assessment-key.pem ec2-user@34.255.179.146

# Check running containers
docker ps

# Test RDS connection
mysql -h <RDS_ENDPOINT> -u admin -p devopsdb
```

## 📊 Project Structure

```bash
medici-assessment/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── docker/
│   ├── Dockerfile
│   └── index.html
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │       ├── vpc/
│   │       ├── security-groups/
│   │       ├── ec2/
│   │       ├── rds/
│   │       └── ecr/
│   └── terragrunt.hcl
├── infrastructure.sh
├── deploy-all.sh
├── destroy-all.sh
├── README.md
├── TESTING_GUIDE.md
├── ARCHITECTURE.md
├── DEPLOYMENT_GUIDE.md
└── CTO_PRESENTATION.md
```

## 🔐 Security

- VPC Isolation: Private subnets for database
- Security Groups: Least privilege access
- Secrets Management: AWS Secrets Manager for RDS password
- IAM: Proper role-based access control
- Encryption: RDS encryption enabled
- Backup: Automated daily backups with 7-day retention

## 💰 Cost Optimization

- t3.micro EC2: Free tier eligible
- db.t3.micro RDS: Free tier eligible
- NAT Gateway: ~$32/month (consider VPC endpoints for production)
- ECR: Pay per GB stored (~$0.10/GB/month)
- Data Transfer: Minimal within VPC

Estimated Monthly Cost: $35-50 (excluding data transfer)

## 📈 Monitoring & Logging

- CloudWatch Logs: RDS error, general, and slow query logs
- EC2 Logs: Available via Systems Manager Session Manager
- Docker Logs: Accessible via docker logs nginx-server

## 🔄 Maintenance

### Regular Tasks
- Monitor ECR image storage
- Review RDS backups
- Check security group rules
- Update Docker base images

### Scaling
- Increase EC2 instance type for more traffic
- Enable RDS read replicas for read-heavy workloads
- Use Application Load Balancer for multiple EC2 instances

## 📚 Documentation

Complete documentation is available:

- [README.md](README.md) - Project overview and quick start
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Comprehensive testing procedures
- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed system architecture and design
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Step-by-step deployment instructions
- [CTO_PRESENTATION.md](CTO_PRESENTATION.md) - Executive summary and business case

## 🛠️ Troubleshooting

### EC2 Not Accessible

```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx
aws ec2 describe-instances --instance-ids i-xxxxx
```

### RDS Connection Failed

```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx
aws rds describe-db-instances --db-instance-identifier medici-assessment-mysql-db
```

### GitHub Actions Failing
- Check secrets are set correctly
- Verify AWS credentials have proper permissions
- Check EC2 security group allows SSH from GitHub runners

## 📞 Support

For issues or questions:
1. Check [TESTING_GUIDE.md](TESTING_GUIDE.md)
2. Review [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
3. Check GitHub Actions logs
4. Review AWS CloudWatch logs

## 📄 License

This project is part of the Medici Assessment.

## 👤 Author

Jason Laskey

## 🔗 Links

- GitHub: https://github.com/jasonklaskey/medici-assessment
- AWS Region: eu-west-1 (Ireland)
- Web Server: http://34.255.179.146

## 📊 Architecture Diagrams

- [Network Architecture Diagram](./docs/NETWORK_DIAGRAM.md) - ASCII network visualization
- [Visual Architecture Diagram](./docs/diagram-2.md) - Interactive Mermaid diagram
