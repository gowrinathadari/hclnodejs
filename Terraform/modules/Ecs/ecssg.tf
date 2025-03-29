# Create a security group for the ECS service
resource "aws_security_group" "ecs_sg_new" {
  
  name        = "ecs-Sg_new"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = var.vpc_id  # Reference the VPC ID from the variable

    # Allow inbound traffic on port 3000 (for application on port 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world; consider restricting this in production
  }

  # Allow inbound traffic on port 3001 (for application on port 3001)
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world; consider restricting this in production
  }

  # Allow all outbound traffic (default rule)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "ECS Application Security Group"
  }
}

variable "vpc_id" {
  
}