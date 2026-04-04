# Architecture Write-up

## Overview
This project implements a complete DevOps lifecycle for a Node.js application,
covering containerization, CI pipeline automation, and cloud infrastructure
provisioning on AWS using Infrastructure as Code.

---

## Architecture Diagram

Developer (Local)
|
| git push
↓
GitHub Repository (main branch)
|
| webhook trigger
↓
AWS CodePipeline
|
↓
┌─────────────────────────────────┐
│         AWS CodeBuild           │
│                                 │
│  1. Install Node.js deps        │
│  2. Run Jest unit tests         │
│  3. Build Docker image          │
│  4. Trivy security scan         │
│  5. Push image to ECR           │
│  6. Deploy to EC2 via SSM       │
└─────────────────────────────────┘
|
↓
AWS ECR (Docker Image Registry)
|
↓
┌─────────────────────────────────┐
│         AWS VPC                 │
│                                 │
│  ┌──────────────────────────┐   │
│  │   Public Subnet          │   │
│  │                          │   │
│  │   EC2 t2.micro           │   │
│  │   └── Docker Container   │   │
│  │       └── Node.js App    │   │
│  │           Port: 3000     │   │
│  └──────────────────────────┘   │
│                                 │
│  Internet Gateway               │
│  Route Tables                   │
│  Security Groups                │
└─────────────────────────────────┘

---

## Tool Choices & Justification

### 1. Node.js + Express
- Lightweight and fast for building REST APIs
- Large ecosystem with npm packages
- Easy to containerize with Docker
- Perfect for demonstrating DevOps pipeline

### 2. Docker — Multi-stage Build
The Dockerfile uses two stages:

**Stage 1 (Builder):**
- Installs all dependencies including devDependencies
- Runs unit tests to validate the build
- Ensures only tested code moves forward

**Stage 2 (Production):**
- Uses minimal `node:18-alpine` base image
- Installs only production dependencies
- Runs as non-root user for security
- Results in a smaller, more secure image

**Why multi-stage?**
- Reduces final image size significantly
- Separates build tools from runtime
- Improves security by excluding dev dependencies
- Follows Docker best practices

### 3. AWS ECR (Elastic Container Registry)
- Native integration with AWS services
- No additional authentication complexity
- Free tier: 500MB storage
- Automatic image scanning on push
- Lifecycle policies to manage old images

### 4. AWS CodePipeline + CodeBuild
- Fully managed — no Jenkins server to maintain
- Native integration with ECR, IAM, SSM
- Free tier: 1 pipeline free, 100 build minutes/month
- Automatically triggers on every GitHub push
- CloudWatch logs for debugging

**Why not Jenkins?**
- Jenkins requires a dedicated server to run
- Additional maintenance overhead
- More complex setup for this assessment scope
- CodeBuild is more cost-effective for small projects

### 5. Trivy Security Scanner
- Open source and free
- Easy to install in CodeBuild
- Scans Docker images for CVEs
- Supports HIGH and CRITICAL severity filtering
- Industry standard security scanning tool

### 6. Terraform
- Industry standard Infrastructure as Code tool
- Declarative syntax — easy to read and maintain
- Modular structure for reusability
- State management for tracking resources
- Single `terraform destroy` to clean up everything

**Why not CloudFormation?**
- Terraform is cloud-agnostic
- Better module system
- Cleaner syntax (HCL vs JSON/YAML)
- Larger community and more examples
- Preferred by most DevOps engineers

### 7. AWS EC2 t2.micro
- Free tier eligible (750 hours/month)
- Sufficient compute for demo application
- Simple to provision with Terraform
- Docker runs natively on Amazon Linux 2

**Why not ECS Fargate or EKS?**
- ECS Fargate and EKS are NOT free tier eligible
- EC2 t2.micro achieves the same goal for this assessment
- Demonstrates containerization without additional cost
- Task explicitly mentions EC2 as valid compute option

### 8. AWS SSM (Systems Manager)
- Used to deploy container to EC2 after pipeline
- No need for SSH keys or bastion hosts
- More secure than direct SSH access
- Fully managed by AWS

---

## Infrastructure Components

### VPC (Virtual Private Cloud)
- CIDR: `10.0.0.0/16`
- Provides isolated network environment
- Contains all application resources

### Subnets
- 1 Public subnet: `10.0.1.0/24`
- Located in `ap-south-1a`
- EC2 instance deployed here

### Internet Gateway
- Attached to VPC
- Enables internet access for EC2

### Route Tables
- Public route table
- Routes `0.0.0.0/0` traffic to Internet Gateway

### Security Groups
- Inbound: ports 22 (SSH), 80 (HTTP), 3000 (App)
- Outbound: all traffic allowed

### IAM Roles
- **EC2 Role:** ECR read access + SSM access
- **CodeBuild Role:** ECR push + S3 + SSM + EC2 describe
- **CodePipeline Role:** S3 + CodeBuild + CodeStar

---

## CI Pipeline Stages

| Stage | Tool | Description |
|---|---|---|
| Source | CodePipeline | Pulls code from GitHub on push to main |
| Install | CodeBuild | Installs Node.js dependencies |
| Test | CodeBuild | Runs Jest unit tests |
| Build | CodeBuild | Builds multi-stage Docker image |
| Security Scan | Trivy | Scans image for vulnerabilities |
| Push | CodeBuild | Tags and pushes image to ECR |
| Deploy | SSM | Automatically deploys to EC2 |

---

## Tradeoffs

| Decision | Chosen | Alternative | Reason |
|---|---|---|---|
| Compute | EC2 t2.micro | ECS Fargate | Free tier, cost-effective |
| CI Tool | CodeBuild | Jenkins | Managed, no server needed |
| IaC | Terraform | CloudFormation | Better modularity |
| Registry | ECR | DockerHub | Native AWS integration |
| Deployment | SSM | SSH/Ansible | More secure, no keys needed |

---

## Security Considerations
- Non-root user in Docker container
- IAM roles with least privilege principle
- Security groups restrict inbound traffic
- Trivy scans for vulnerabilities before push
- No hardcoded credentials anywhere
- SSM used instead of SSH for EC2 access

---
