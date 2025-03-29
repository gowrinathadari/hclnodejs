terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"  # Change this to your preferred AWS region
}


resource "aws_vpc" "hcl" {
  cidr_block              = "10.0.0.0/16"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true
  enable_dns_support =  true

  tags      = {
    Name    = "hcl-vpc"
    
  }
}

#Create and attach Internet gateway to Vpc
resource "aws_internet_gateway" "hcl-igw" {
  vpc_id = aws_vpc.hcl.id
  tags = {
    Name = "hcl-igw"
  }

}

resource "aws_internet_gateway_attachment" "hcl-igw-attach" {
  vpc_id             = aws_vpc.hcl.id
  internet_gateway_id = aws_internet_gateway.hcl-igw.id

    depends_on = [
        aws_internet_gateway.hcl-igw
    ]
  
}



#create public subnets
resource "aws_subnet" "pub_sub_1" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "pub_sub_1"
  }
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_sub_2"
  }
}

resource "aws_subnet" "pub_sub_3" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_sub_3"
  }
}

#Create private subnets

resource "aws_subnet" "pvt_sub_1" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "pvt_sub_1"
  }
}

resource "aws_subnet" "pvt_sub_2" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "pvt_sub_2"
  }
}

resource "aws_subnet" "pvt_sub_3" {
  vpc_id     = aws_vpc.hcl.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-south-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "pvt_sub_3"
  }
}

#Create route table for public subnets

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.hcl.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.hcl-igw.id
    }
    tags = {
        Name = "hcl-public-rt"
    }   
}

#Associate Public Subnets to public Route Table

resource "aws_route_table_association" "pub_sub_1" {
  subnet_id      = aws_subnet.pub_sub_1.id
  route_table_id = aws_route_table.pub_rt.id
}
resource "aws_route_table_association" "pub_sub_2" {
  subnet_id      = aws_subnet.pub_sub_2.id
  route_table_id = aws_route_table.pub_rt.id
}
resource "aws_route_table_association" "pub_sub_3" {
  subnet_id      = aws_subnet.pub_sub_3.id
  route_table_id = aws_route_table.pub_rt.id
}

#Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"
  tags = {
    Name = "hcl-nat-eip"
  }
}
#create NAT GATEWAY for private subnets
resource "aws_nat_gateway" "hcl_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_sub_1.id
  depends_on = [
    aws_internet_gateway.hcl-igw
  ]
  tags = {
    Name = "hcl-nat-gw"
  }
}

#Create Private Route Tables

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.hcl.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.hcl_nat_gw.id
  }
}

#Associate Private Subnets to Private Route Table
resource "aws_route_table_association" "pvt_sub_1" {
  subnet_id      = aws_subnet.pvt_sub_1.id
  route_table_id = aws_route_table.pvt_rt.id
}
resource "aws_route_table_association" "pvt_sub_2" {
  subnet_id      = aws_subnet.pvt_sub_2.id
  route_table_id = aws_route_table.pvt_rt.id
}
resource "aws_route_table_association" "pvt_sub_3" {
  subnet_id      = aws_subnet.pvt_sub_3.id
  route_table_id = aws_route_table.pvt_rt.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "Bastion-Sg"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.hcl.id

# SSH
  ingress {
    description = "SSH from any IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Jenkins-port-8080
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Jenkins-agent-port
  ingress {
    description = "Jenkins-agent port"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-Sg"
  }
}

# Create a security group for the ECS service
resource "aws_security_group" "ecs_sg" {
  
  name        = "ecs-Sg"
  description = "Allow SSH & HTTP inbound traffic"
  vpc_id      = aws_vpc.hcl.id

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