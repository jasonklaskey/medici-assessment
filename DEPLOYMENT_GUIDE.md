# Deployment Guide - Medici Assessment

Complete step-by-step guide for deploying the AWS DevOps infrastructure and CI/CD pipeline.

## Prerequisites

Before you begin, ensure you have:
- AWS Account with appropriate permissions
- Terraform & Terragrunt installed
- Docker installed locally
- GitHub account
- AWS CLI configured
- SSH key pair created
- Git installed

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/jasonklaskey/medici-assessment.git
cd medici-assessment
```

### 2. Configure AWS Credentials

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, and default region (eu-west-1).

### 3. Install Dependencies

```bash
# Install Terraform
brew install terraform

# Install Terragrunt
brew install terragrunt

# Install Docker
brew install docker
```

## Infrastructure Deployment

### Step 1: Review Terraform Configuration

```bash
cd terraform/environments/dev
ls -la
```

Review the terragrunt.hcl and main.tf files to understand the infrastructure.

### Step 2: Initialize Terragrunt

```bash
terragrunt init
```

This downloads required providers and modules.

### Step 3: Plan Infrastructure

```bash
terragrunt plan-all
```

Review the plan to see what resources will be created.

### Step 4: Deploy Infrastructure

```bash
./infrastructure.sh
```

The script will:
1. Show you the Terraform plan
2. Ask if you want to deploy
3. Deploy all infrastructure
4. Ask if you want to destroy (optional)

Type 'yes' when prompted to deploy.

### Step 5: Verify Deployment

```bash
aws ec2 describe-instances --region eu-west-1 --output table
aws rds describe-db-instances --region eu-west-1 --output table
aws ecr describe-repositories --region eu-west-1 --output table
```

Verify all resources are created successfully.

## Application Deployment

### Step 1: Build Docker Image Locally

```bash
cd docker
docker build -t medici-assessment:latest .
```

### Step 2: Test Docker Image Locally

```bash
docker run -d -p 8080:80 --name test-nginx medici-assessment:latest
curl http://localhost:8080
docker stop test-nginx
docker rm test-nginx
```

### Step 3: Push to ECR

```bash
# Get ECR login token
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 205883165886.dkr.ecr.eu-west-1.amazonaws.com

# Tag image
docker tag medici-assessment:latest 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:latest

# Push to ECR
docker push 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:latest
```

### Step 4: Deploy to EC2

SSH into your EC2 instance:

```bash
ssh -i /path/to/key.pem ec2-user@<EC2_PUBLIC_IP>
```

On the EC2 instance:

```bash
# Login to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 205883165886.dkr.ecr.eu-west-1.amazonaws.com

# Pull latest image
docker pull 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:latest

# Stop old container
docker stop nginx-server || true
docker rm nginx-server || true

# Run new container
docker run -d -p 80:80 --name nginx-server 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:latest
```

### Step 5: Verify Application

```bash
curl http://<EC2_PUBLIC_IP>
```

You should see the Medici Assessment homepage.

## GitHub Actions Setup

### Step 1: Create GitHub Secrets

Go to your GitHub repository Settings > Secrets and add:

- AWS_ACCESS_KEY_ID: Your AWS access key
- AWS_SECRET_ACCESS_KEY: Your AWS secret key
- EC2_PUBLIC_IP: Your EC2 instance public IP
- EC2_PRIVATE_KEY: Your SSH private key content

### Step 2: Verify Workflow File

```bash
cat .github/workflows/deploy.yml
```

The workflow should trigger on push to main branch.

### Step 3: Test Workflow

Make a small change and push:

```bash
echo '# Test' >> docker/index.html
git add docker/index.html
git commit -m 'test: Trigger workflow'
git push origin main
```

Go to GitHub Actions and monitor the workflow.

## Database Setup

### Step 1: Connect to RDS

```bash
mysql -h <RDS_ENDPOINT> -u admin -p devopsdb
```

Enter the password when prompted.

### Step 2: Create Tables

```bash
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  message TEXT,
  level VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Step 3: Verify Tables

```bash
SHOW TABLES;
DESCRIBE users;
DESCRIBE logs;
```

## Monitoring & Logs

### View EC2 Logs

```bash
ssh -i /path/to/key.pem ec2-user@<EC2_PUBLIC_IP>
docker logs nginx-server
```

### View RDS Logs

```bash
aws rds describe-db-log-files --db-instance-identifier medici-assessment-mysql-db --region eu-west-1
```

### View CloudWatch Logs

```bash
aws logs describe-log-groups --region eu-west-1
aws logs tail /aws/rds/instance/medici-assessment-mysql-db/error --follow
```

## Troubleshooting

### Issue: Terraform Plan Fails

Solution:
- Check AWS credentials: aws sts get-caller-identity
- Check IAM permissions
- Verify region is set correctly

### Issue: EC2 Instance Not Accessible

Solution:
- Check security group allows SSH (port 22)
- Check security group allows HTTP (port 80)
- Verify instance is running: aws ec2 describe-instances

### Issue: Docker Container Won't Start

Solution:
- Check logs: docker logs nginx-server
- Check image exists: docker images
- Check port 80 is not in use: lsof -i :80

### Issue: RDS Connection Failed

Solution:
- Check security group allows MySQL (port 3306)
- Check RDS is running: aws rds describe-db-instances
- Verify credentials are correct

### Issue: GitHub Actions Workflow Fails

Solution:
- Check secrets are set correctly
- Check AWS credentials have permissions
- Check EC2 security group allows SSH
- Review workflow logs in GitHub Actions

## Rollback Procedures

### Rollback Infrastructure

```bash
cd terraform/environments/dev
terragrunt destroy-all
```

Type 'yes' when prompted.

### Rollback Application

```bash
# SSH into EC2
ssh -i /path/to/key.pem ec2-user@<EC2_PUBLIC_IP>

# Stop current container
docker stop nginx-server

# Run previous version
docker run -d -p 80:80 --name nginx-server 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:previous-tag
```

## Maintenance Tasks

### Weekly Tasks
- Monitor ECR image storage
- Review RDS backups
- Check security group rules
- Monitor CloudWatch logs

### Monthly Tasks
- Update Docker base images
- Review and optimize costs
- Test disaster recovery
- Update documentation

### Quarterly Tasks
- Review security posture
- Plan capacity upgrades
- Review and update IAM policies
- Conduct security audit

## Scaling the Infrastructure

### Horizontal Scaling

To add more EC2 instances:

```bash
# Modify terraform/environments/dev/ec2/main.tf
# Change instance_count from 1 to 2+
terragrunt apply
```

### Vertical Scaling

To increase instance size:

```bash
# Modify terraform/environments/dev/ec2/main.tf
# Change instance_type from t3.micro to t3.small
terragrunt apply
```

### Database Scaling

To increase RDS capacity:

```bash
# Modify terraform/environments/dev/rds/main.tf
# Change instance_class or allocated_storage
terragrunt apply
```

## Disaster Recovery

### Backup Strategy

- RDS: Automated daily backups with 7-day retention
- ECR: Images stored with lifecycle policy
- Terraform State: Stored in S3 with versioning

### Recovery Procedures

1. Restore from RDS backup
2. Redeploy infrastructure with Terraform
3. Redeploy application from ECR

## Security Best Practices

- Keep AWS credentials secure
- Use IAM roles instead of access keys
- Enable MFA on AWS account
- Regularly rotate credentials
- Use VPC security groups properly
- Enable RDS encryption
- Monitor CloudWatch logs
- Keep dependencies updated

## Support & Documentation

- See TESTING_GUIDE.md for testing procedures
- See ARCHITECTURE.md for system design
- See README.md for project overview
- See CTO_PRESENTATION.md for business case
