# Testing Guide - Medici Assessment

Complete step-by-step testing procedures for the AWS DevOps infrastructure and CI/CD pipeline.

## 📋 Test Overview

This guide walks you through testing every component of the infrastructure to ensure everything is working correctly.

| Component | Test Type | Purpose | Status |
|-----------|-----------|---------|--------|
| VPC & Networking | Infrastructure | Verify network isolation and routing | ✅ PASS |
| EC2 Instance | Compute | Verify web server is accessible | ✅ PASS |
| RDS Database | Database | Verify database connectivity | ✅ PASS |
| ECR Repository | Container Registry | Verify image storage | ✅ PASS |
| Web Server | Application | Verify application is serving content | ✅ PASS |
| GitHub Actions | CI/CD | Verify automated deployment pipeline | ✅ PASS |
| Docker Deployment | Containerization | Verify container is running | ✅ PASS |

---

## 🧪 Test 1: VPC & Networking

**Why Test This?**
The VPC is the foundation of your infrastructure. Testing it ensures network isolation, proper subnet configuration, internet connectivity, and NAT Gateway access.

### 1.1 Verify VPC Created

**What This Tests:** Confirms the VPC exists with correct CIDR block

**Step-by-Step:**
1. Run: aws ec2 describe-vpcs --filters "Name=tag:Name,Values=medici-assessment-vpc" --region eu-west-1 --output table
2. Look for output table

**Expected Output:**
- VpcId: vpc-00fc5214e94436ece
- CidrBlock: 10.0.0.0/16
- State: available

**What It Means:**
- ✅ VPC exists and is available
- ✅ CIDR block is correct
- ✅ It's not the default VPC

---

### 1.2 Verify Subnets

**What This Tests:** Confirms all 4 subnets exist (2 public, 2 private)

**Step-by-Step:**
1. Run: aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-00fc5214e94436ece" --region eu-west-1 --output table
2. Count subnets in output

**Expected Output:**
- 2 Public Subnets: 10.0.1.0/24, 10.0.2.0/24
- 2 Private Subnets: 10.0.10.0/24, 10.0.11.0/24
- Spread across 2 AZs

---

## 🧪 Test 2: EC2 Instance

**Why Test This?**
The EC2 instance runs your web server. Testing ensures it's running, accessible, and properly configured.

### 2.1 Verify EC2 Running

**What This Tests:** Confirms EC2 instance exists and is running

**Step-by-Step:**
1. Run: aws ec2 describe-instances --filters "Name=tag:Name,Values=medici-assessment-web-server" --region eu-west-1 --output table
2. Look for State field

**Expected Output:**
- InstanceId: i-0f869128b090fdeba
- State: running
- PublicIpAddress: 34.255.179.146
- PrivateIpAddress: 10.0.1.80

---

### 2.2 Test SSH Access

**What This Tests:** Confirms you can SSH into the EC2 instance

**Step-by-Step:**
1. Run: ssh -i /Users/jasonlaskey/medici-assessment-key.pem ec2-user@34.255.179.146 "echo 'SSH works!'"

**Expected Output:**
- SSH works!

**What It Means:**
- ✅ SSH key is valid
- ✅ Security group allows SSH
- ✅ You can remotely access the instance

---

## 🧪 Test 3: Web Server

**Why Test This?**
The web server serves your application. Testing ensures Nginx is running, Docker container works, and content is accessible.

### 3.1 Test HTTP Access

**What This Tests:** Confirms web server is accessible from your computer

**Step-by-Step:**
1. Run: curl http://34.255.179.146
2. Look at HTML output

**Expected Output:**
- Beautiful HTML page with CI/CD badges
- Status: 200 OK

**What It Means:**
- ✅ Web server is running
- ✅ Port 80 is accessible
- ✅ Nginx is serving content

---

### 3.2 Verify Docker Container

**What This Tests:** Confirms Docker container is running

**Step-by-Step:**
1. SSH into EC2: ssh -i /Users/jasonlaskey/medici-assessment-key.pem ec2-user@34.255.179.146
2. Run: docker ps
3. Look for nginx-server container

**Expected Output:**
- Container ID: e3ae4627759d
- Image: 205883165886.dkr.ecr.eu-west-1.amazonaws.com/medici-assessment-ecr:latest
- Status: Up 3 minutes
- Ports: 0.0.0.0:80->80/tcp

---

## 🧪 Test 4: RDS Database

**Why Test This?**
The RDS database stores your data. Testing ensures it's running, accessible, and can read/write data.

### 4.1 Verify RDS Instance

**What This Tests:** Confirms RDS instance exists and is available

**Step-by-Step:**
1. Run: aws rds describe-db-instances --db-instance-identifier medici-assessment-mysql-db --region eu-west-1 --output table

**Expected Output:**
- DBInstanceIdentifier: medici-assessment-mysql-db
- DBInstanceClass: db.t3.micro
- Engine: mysql
- DBInstanceStatus: available
- MultiAZ: true

---

### 4.2 Test RDS Connection

**What This Tests:** Confirms you can connect to the database from EC2

**Step-by-Step:**
1. SSH into EC2
2. Run: mysql -h medici-assessment-mysql-db.c9lvr00r4btz.eu-west-1.rds.amazonaws.com -u admin -p'>1k[*dP$U]eFi7Ek' devopsdb
3. Run: SHOW DATABASES;
4. Run: EXIT;

**Expected Output:**
- Connected successfully
- Database list shown including devopsdb

---

### 4.3 Test RDS Read/Write

**What This Tests:** Confirms you can create, insert, and read data

**Step-by-Step:**
1. Connect to RDS (from previous test)
2. Create table: CREATE TABLE test_connection (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
3. Insert data: INSERT INTO test_connection (message) VALUES ('Connection successful!');
4. Verify: SELECT * FROM test_connection;
5. Exit: EXIT;

**Expected Output:**
- Table created
- Data inserted and retrieved successfully

---

## 🧪 Test 5: GitHub Actions CI/CD

**Why Test This?**
GitHub Actions automates your deployment. Testing ensures workflow triggers, builds, approves, and deploys correctly.

### 5.1 Trigger Workflow

**What This Tests:** Confirms workflow starts when you push code

**Step-by-Step:**
1. Run: cd /Users/jasonlaskey/Projects/medici-assessment
2. Run: echo "# Test $(date)" >> docker/index.html
3. Run: git add docker/index.html
4. Run: git commit -m "Test: Trigger workflow"
5. Run: git push origin main
6. Go to: https://github.com/jasonklaskey/medici-assessment/actions

**Expected Output:**
- New workflow run appears
- Status shows "In progress"

---

### 5.2 Monitor Build Stage

**What This Tests:** Confirms Docker image is built successfully

**Step-by-Step:**
1. In GitHub Actions, click workflow run
2. Click "Build Docker Image" job
3. Watch logs

**Expected Output:**
- ✅ Checkout code
- ✅ Configure AWS credentials
- ✅ Login to Amazon ECR
- ✅ Build and push image
- ✅ Image pushed to ECR

---

### 5.3 Approve Deployment

**What This Tests:** Confirms manual approval gate works

**Step-by-Step:**
1. Wait for "Deploy to EC2" job
2. Click "Review deployments"
3. Select "medici-assessment" environment
4. Click "Approve and deploy"

**Expected Output:**
- Deployment starts
- Status changes to "In progress"

---

### 5.4 Verify Deployment

**What This Tests:** Confirms new image is deployed to EC2

**Step-by-Step:**
1. Wait for deployment to complete
2. Run: curl http://34.255.179.146
3. SSH into EC2 and run: docker ps

**Expected Output:**
- ✅ Deployment complete
- Web server responds with updated content
- Container running latest image

---

## 📊 Complete Test Summary

| Test | Component | Result |
|------|-----------|--------|
| 1.1 | VPC Created | ✅ PASS |
| 1.2 | Subnets Created | ✅ PASS |
| 2.1 | EC2 Running | ✅ PASS |
| 2.2 | SSH Access | ✅ PASS |
| 3.1 | HTTP Access | ✅ PASS |
| 3.2 | Docker Container | ✅ PASS |
| 4.1 | RDS Instance | ✅ PASS |
| 4.2 | RDS Connection | ✅ PASS |
| 4.3 | RDS Read/Write | ✅ PASS |
| 5.1 | Trigger Workflow | ✅ PASS |
| 5.2 | Build Stage | ✅ PASS |
| 5.3 | Approval Gate | ✅ PASS |
| 5.4 | Verify Deployment | ✅ PASS |

**Overall Result: ✅ ALL TESTS PASSED**

---

## 🔄 Continuous Testing

Run these tests weekly:

==>bash
curl http://34.255.179.146
aws rds describe-db-instances --db-instance-identifier medici-assessment-mysql-db --region eu-west-1
==>

---

## 📞 Troubleshooting

**Connection refused on web server:**
- Check EC2 is running
- Check security group allows port 80
- Check Docker container is running

**Access denied on RDS:**
- Check password is correct
- Check security group allows MySQL from EC2
- Check RDS is running

**GitHub Actions fails:**
- Check all secrets are set
- Check AWS credentials have permissions
- Check EC2 security group allows SSH

**Docker image not deploying:**
- Check build stage completed
- Check you approved deployment
- Check EC2 is running

---

## ✅ Testing Checklist

- [ ] Test 1.1: VPC Created
- [ ] Test 1.2: Subnets Created
- [ ] Test 2.1: EC2 Running
- [ ] Test 2.2: SSH Access
- [ ] Test 3.1: HTTP Access
- [ ] Test 3.2: Docker Container
- [ ] Test 4.1: RDS Instance
- [ ] Test 4.2: RDS Connection
- [ ] Test 4.3: RDS Read/Write
- [ ] Test 5.1: Trigger Workflow
- [ ] Test 5.2: Build Stage
- [ ] Test 5.3: Approval Gate
- [ ] Test 5.4: Verify Deployment

Once all tests pass, your infrastructure is ready for production!

## 📚 Related Documentation

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Deployment instructions
- [CTO_PRESENTATION.md](CTO_PRESENTATION.md) - Executive summary
