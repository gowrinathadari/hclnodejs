resource "aws_ecs_cluster" "ecs_cluster" {
  name = "hcl-ecs-cluster"
}
# Create iam role for ECS task execution
# This role is used by ECS to pull images from ECR and send logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}




resource "aws_ecs_task_definition" "ecs_task_1" {
  family                   = "ecs-task-1"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"  # This depends on your network configuration
  requires_compatibilities = ["FARGATE"]  # Use "EC2" if you are using EC2 instances instead of Fargate

  cpu    = "256"  # You can adjust this according to your need
  memory = "512"  # Adjust memory accordingly

  container_definitions = jsonencode([{
    name      = "appointment-service"  # Name of the container
    image     = "539935451710.dkr.ecr.ap-south-1.amazonaws.com/appointment:latest"  # Replace with your actual Docker image URI
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [
      {
        containerPort = 80  # Define the container port that the container will expose
        hostPort      = 80  # Optional if using awsvpc
        protocol      = "tcp"
      }
    ]
  }])
}

# Create Target Group for ALB
resource "aws_lb_target_group" "ecs_target_group" {
  name     = "appointment-service-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"  # Modify this to the correct health check path for your service
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create Application Load Balancer (ALB)
resource "aws_lb" "ecs_lb" {
  name               = "appointment-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg_new.id]
  subnets            = var.subnets

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "appointment-service-alb"
  }
}
resource "aws_ecs_service" "ecs_service_1" {
  name            = "appointment-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_1.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.ecs_sg_new.id]
    assign_public_ip = true
  }

  desired_count = 2

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:123456789012:targetgroup/my-target-group/abc123"
    container_name   = "appointment-service"
    container_port   = 80
  }
 
}