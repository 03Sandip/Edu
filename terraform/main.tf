provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "edu_key" {
  key_name   = "edu-key"
  public_key = file("D:/CODE/App/flutter/EDU/edu_key.pub")
}

resource "aws_security_group" "edu_sg" {
  name        = "edu-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "edu_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.edu_key.key_name
  security_groups = [aws_security_group.edu_sg.name]

  tags = {
    Name = "Edu-Server"
  }
}
