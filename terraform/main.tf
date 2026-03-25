provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "devops-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "devops-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Security group for DevOps cluster"
  vpc_id      = aws_vpc.devops_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K3s API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP for App
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort range for K8s services (includes app, prometheus, grafana)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# Key Pair (assuming it exists or will be created)
# For simplicity, we use an existing key pair name
resource "aws_key_pair" "deployer" {
  key_name   = "devops-key-v2"
  public_key = var.public_key
}

# EC2 Instances
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              curl -sfL https://get.k3s.io | K3S_TOKEN=dsbd-devops-token sh -
              EOF

  tags = {
    Name = "k3s-master"
    Role = "master"
  }
}

resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              curl -sfL https://get.k3s.io | K3S_URL=https://${aws_instance.master.private_ip}:6443 K3S_TOKEN=dsbd-devops-token sh -
              EOF

  tags = {
    Name = "k3s-worker"
    Role = "worker"
  }
}
