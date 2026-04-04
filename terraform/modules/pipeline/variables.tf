variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "ecr_repo_url" {
  description = "ECR Repository URL"
  type        = string
}