resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = local.key_name       # Create a "terra_key" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a "terra_key" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/.ssh/terra_key"
  }

  provisioner "local-exec" { # give "terra_key" permissions!!
    command = "chmod 400 ~/.ssh/terra_key"
  }
}

resource "aws_vpc" "terra-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "terra-vpc-public1" {
  vpc_id     = aws_vpc.terra-vpc.id
  availability_zone = var.availability_zone.a
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public1-${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

resource "aws_route_table" "terra-vpc" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id        = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route-${var.vpc_name}"
  }
}

resource "aws_route_table_association" "terra-vpc" {
  subnet_id      = aws_subnet.terra-vpc-public1.id
  route_table_id = aws_route_table.terra-vpc.id
}

resource "aws_security_group" "terra-sg" {
  name        = var.terra_sg
  vpc_id      = aws_vpc.terra-vpc.id
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "terra_ec2" {
  depends_on = [aws_key_pair.kp, aws_subnet.terra-vpc-public1, aws_security_group.terra-sg]
  ami               = local.local-ami
  instance_type     = var.ec2_instance_type
  availability_zone = var.availability_zone.a
  subnet_id         = aws_subnet.terra-vpc-public1.id
  vpc_security_group_ids = [aws_security_group.terra-sg.id]
  key_name          = local.key_name

  tags = {
    Name = var.terra_ec2
  }

}