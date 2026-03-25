variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  default     = "ami-0030e4319cbf4dbf2" # us-east-1 Ubuntu 22.04 LTS
}

variable "public_key" {
  description = "SSH public key to access EC2 instances"
}
