terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# ECR Module
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
  environment     = var.environment
}

# VPC Module
module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  aws_region  = var.aws_region
}

# IAM Module
module "iam" {
  source          = "./modules/iam"
  environment     = var.environment
  repository_name = var.repository_name
}

# EC2 Module
module "ec2" {
  source               = "./modules/ec2"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_id
  ecr_repo_url         = module.ecr.repository_url
  iam_instance_profile = module.iam.instance_profile_name
  security_group_id    = module.vpc.security_group_id
}

# Include pipeline
module "pipeline" {
  source          = "./modules/pipeline"
  environment     = var.environment
  aws_region      = var.aws_region
  repository_name = var.repository_name
  ecr_repo_url    = module.ecr.repository_url
}