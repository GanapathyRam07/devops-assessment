data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [data.aws_security_group.ec2.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    # Login to ECR
    aws ecr get-login-password --region ap-south-1 | \
    docker login --username AWS --password-stdin ${var.ecr_repo_url}

    # Pull and run the container
    docker pull ${var.ecr_repo_url}:latest
    docker run -d -p 3000:3000 --name app ${var.ecr_repo_url}:latest
  EOF

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
  }
}

data "aws_security_group" "ec2" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-ec2-sg"]
  }
}