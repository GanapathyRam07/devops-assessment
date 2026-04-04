variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "devops-assessment-app"
}