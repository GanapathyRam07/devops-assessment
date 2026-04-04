output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = module.ecr.repository_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ec2_public_ip" {
  description = "EC2 Instance Public IP"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "EC2 Instance Public DNS"
  value       = module.ec2.public_dns
}