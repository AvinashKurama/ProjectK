provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIASTNT7JWUJJHYFZUY"
  secret_key = "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"
}

resource "aws_vpc" "VPC1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Dove"
  }
}

resource "aws_subnet" "Pub" {
  vpc_id     = aws_vpc.VPC1.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public-SN"
  }
}

resource "aws_subnet" "Priv" {
  vpc_id     = aws_vpc.VPC1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private-SN"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC1.id

  tags = {
    Name = "IGW-SN1"
  }
}

resource "aws_eip" "EIP" {
  vpc = true
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.Priv.id

  tags = {
    Name = "Private-NGW"
  }
}

resource "aws_route_table" "RT-1" {
  vpc_id = aws_vpc.VPC1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "RT-public"
  }
}

resource "aws_route_table" "RT-2" {
  vpc_id = aws_vpc.VPC1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }
  tags = {
    Name = "RT-private"
  }
}

resource "aws_route_table_association" "as-1" {
  subnet_id      = aws_subnet.Pub.id
  route_table_id = aws_route_table.RT-1.id
}

resource "aws_route_table_association" "as-2" {
  subnet_id      = aws_subnet.Priv.id
  route_table_id = aws_route_table.RT-2.id
}

resource "aws_security_group" "My-SG" {
  name        = "SG-1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.VPC1.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.VPC1.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-1"
  }
}

resource "aws_instance" "dove1" {
  ami                    = "ami-068257025f72f470d"
  instance_type          = "t2.micro"
  availability_zone      = "ap-south-1b"
  key_name               = "rootkey"
  vpc_security_group_ids = [aws_security_group.My-SG.id]
  monitoring             = true
  subnet_id              = "subnet-0e471d34fce9e1c17"
  tags = {
    Name = "Dove-instance"
    type = "terraform Vpc type"
  }
}
resource "aws_instance" "dove2-pri" {
  ami                    = "ami-068257025f72f470d"
  instance_type          = "t2.micro"
  availability_zone      = "ap-south-1b"
  key_name               = "rootkey"
  vpc_security_group_ids = [aws_security_group.My-SG.id]
  monitoring             = true
  subnet_id              = "subnet-0e471d34fce9e1c17"
  tags = {
    Name = "Dove-instance2"
    type = "terraform Vpc type"
  }
}