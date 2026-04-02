provider "aws" {
  region = "eu-west-3" # Paris
}

# 1. Recherche dynamique de l'image Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Groupe de Sécurité corrigé (Auto-communication ajoutée)
resource "aws_security_group" "k3s_sg" {
  name        = "k3s_sg"
  description = "Security group for K3s cluster"

  # Accès SSH (Externe)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API Kubernetes (Externe)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application Flask (Externe)
  ingress {
    from_port   = 30001
    to_port     = 30001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- LA RÈGLE MANQUANTE : Autoriser les nœuds à se parler ---
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true 
  }

  # Tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Instance Master
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "the_working_key_v2"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = { Name = "k3s-master" }
}

# 4. Instance Worker
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "the_working_key_v2"
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  tags = { Name = "k3s-worker" }
}

# 5. Outputs pour Ansible
output "master_public_ip" { value = aws_instance.master.public_ip }
output "worker_public_ip" { value = aws_instance.worker.public_ip }
output "worker_private_ip" { value = aws_instance.worker.private_ip }