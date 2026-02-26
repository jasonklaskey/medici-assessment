Markdown Live Preview
Reset
Copy
Export PDF

170171172173174175176177178179180181182183184185186187188189190191192196197198199200202203204205206193195194201
```

---

### GitHub Actions Failing
- Check secrets are set correctly
- Verify AWS credentials have proper permissions
- Check EC2 security group allows SSH from GitHub runners

## Support

RDS Connection Failed
1 of 1
Medici Assessment - AWS DevOps Infrastructure
A complete, production-ready AWS DevOps infrastructure with automated CI/CD pipeline, containerization, and infrastructure-as-code.

Project Overview
This project demonstrates a fully automated DevOps pipeline that:

Provisions AWS infrastructure using Terraform & Terragrunt
Builds Docker images via GitHub Actions
Pushes images to Amazon ECR
Deploys to EC2 with manual approval gates
Manages databases with RDS MySQL
Implements security best practices
Quick Start
Prerequisites
AWS Account with appropriate permissions
Terraform & Terragrunt installed
Docker installed
GitHub account
AWS CLI configured
Deployment
git clone https://github.com/jasonklaskey/medici-assessment.git
cd medici-assessment
./infrastructure.sh
The script will:

Show you the Terraform plan
Ask if you want to deploy
Deploy all infrastructure
Ask if you want to destroy (optional)
Infrastructure Components
VPC & Networking
VPC CIDR: 10.0.0.0/16
Public Subnets: 10.0.1.0/24, 10.0.2.0/24 (2 AZs)
Private Subnets: 10.0.10.0/24, 10.0.11.0/24 (2 AZs)
Internet Gateway: For public subnet internet access
NAT Gateway: For private subnet outbound internet access
Compute
EC2 Instance: t3.micro (Amazon Linux 2)
Docker: Nginx web server
Security Group: Allows HTTP (80), HTTPS (443), SSH (22)
Database
RDS MySQL: db.t3.micro
Multi-AZ: Yes (High Availability)
Database: devopsdb
Backup Retention: 7 days
Security Group: Only allows MySQL (3306) from EC2
Container Registry
ECR Repository: medici-assessment-ecr
Image Scanning: Enabled on push
Lifecycle Policy: Keep last 10 images
CI/CD Pipeline
GitHub Actions Workflow
Trigger: Push to main branch or manual trigger

Build Stage:

Checkout code
Configure AWS credentials
Login to ECR
Build Docker image
Push to ECR
Manual Approval: Workflow pauses for approval

Deploy Stage:

Configure AWS credentials
SSH into EC2
Login to ECR
Pull latest image
Stop old container
Start new container
Workflow File
Location: .github/workflows/deploy.yml
Environment: medici-assessment (requires approval)
Testing
See TESTING_GUIDE.md for comprehensive testing procedures.

Quick Tests
curl http://34.255.179.146
ssh -i medici-assessment-key.pem ec2-user@34.255.179.146
docker ps
mysql -h RDS_ENDPOINT -u admin -p devopsdb
Project Structure
├── deploy-all.sh
├── destroy-all.sh
├── docker
│   ├── Dockerfile
│   └── index.html
├── docs
├── infrastructure.sh
├── install-vscode-extensions.sh
├── README.md
├── terraform
│   └── environments
│       └── dev
│           ├── ec2
│           │   ├── main.tf
│           │   └── terragrunt.hcl
│           ├── ecr
│           │   ├── main.tf
│           │   └── terragrunt.hcl
│           ├── rds
│           │   ├── main.tf
│           │   └── terragrunt.hcl
│           ├── security-groups
│           │   ├── main.tf
│           │   └── terragrunt.hcl
│           └── vpc
│               ├── main.tf
│               ├── terragrunt.hcl
│               └── variables.tf
├── terragrunt.hcl
├── TESTING_GUIDE.md
├── ARCHITECTURE.md
├── DEPLOYMENT_GUIDE.md
└── CTO_PRESENTATION.md
Security
VPC Isolation: Private subnets for database
Security Groups: Least privilege access
Secrets Management: AWS Secrets Manager for RDS password
IAM: Proper role-based access control
Encryption: RDS encryption enabled
Backup: Automated daily backups with 7-day retention
Cost Optimization
t3.micro EC2: Free tier eligible
db.t3.micro RDS: Free tier eligible
NAT Gateway: ~$32/month (consider VPC endpoints for production)
ECR: Pay per GB stored (~$0.10/GB/month)
Data Transfer: Minimal within VPC
Estimated Monthly Cost: $35-50 (excluding data transfer)

Monitoring & Logging
CloudWatch Logs: RDS error, general, and slow query logs
EC2 Logs: Available via Systems Manager Session Manager
Docker Logs: Accessible via docker logs nginx-server
Maintenance
Regular Tasks
Monitor ECR image storage
Review RDS backups
Check security group rules
Update Docker base images
Scaling
Increase EC2 instance type for more traffic
Enable RDS read replicas for read-heavy workloads
Use Application Load Balancer for multiple EC2 instances
Documentation
TESTING_GUIDE.md - Complete testing procedures
ARCHITECTURE.md - Detailed architecture
DEPLOYMENT_GUIDE.md - Step-by-step deployment
CTO_PRESENTATION.md - Executive summary
Troubleshooting
EC2 Not Accessible
aws ec2 describe-security-groups --group-ids sg-xxxxx
aws ec2 describe-instances --instance-ids i-xxxxx
RDS Connection Failed
aws ec2 describe-security-groups --group-ids sg-xxxxx
aws rds describe-db-instances --db-instance-identifier medici-assessment-mysql-db
GitHub Actions Failing
Check secrets are set correctly
Verify AWS credentials have proper permissions
Check EC2 security group allows SSH from GitHub runners
Support
For issues or questions:

Check TESTING_GUIDE.md
Review DEPLOYMENT_GUIDE.md
Check GitHub Actions logs
Review AWS CloudWatch logs
License
This project is part of the Medici Assessment.

Author
Jason Laskey

Links
GitHub: https://github.com/jasonklaskey/medici-assessment
AWS Region: eu-west-1 (Ireland)
Web Server: http://34.255.179.146
### RDS Connection Failed, 1 of 1 found for 'RDS Connection Failed', at 196:5
