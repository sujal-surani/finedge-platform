data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_key_pair" "k3s_key" {
  key_name   = "finedge-k3s-key"
  public_key = file("ec2-key.pub")
}

resource "aws_security_group" "k3s_sg" {
  name        = "finedge-k3s-sg"
  description = "Allow SSH, HTTP, HTTPS, and Kube API traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # For the frontend application
  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "k3s_server" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.small"

  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.k3s_key.key_name

  # Bootstrap k3s without Flannel and without default network policies
  user_data = file("userDataScript.sh")

  tags = {
    Name = "FinEdge-k3s-Server"
  }
}

# 6. Outputs
output "instance_public_ip" {
  value       = aws_instance.k3s_server.public_ip
  description = "The public IP of the k3s server"
}