variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR Repository URL"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile Name"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID from VPC module"
  type        = string
}