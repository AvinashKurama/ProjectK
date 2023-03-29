resource "aws_vpc" "VPC_1" {
  cidr_block = var.cidr

  tags = {
    Name = "sanju"
  }
}

resource "aws_subnet" "Pub_1" {
  vpc_id            = aws_vpc.VPC_1.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Avinash_SUB1"
  }
}

resource "aws_subnet" "Prv_2" {
  vpc_id            = aws_vpc.VPC_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Avinash_SUB2"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-02eb7a4783e7e9317"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Pub_1.id

  tags = {
    Name = "My_Instance"
  }
}

resource "aws_instance" "Dev" {
  ami           = "ami-02eb7a4783e7e9317"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Prv_2.id

  tags = {
    Name = "My_Instance_2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC_1.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "Pub_RT" {
  vpc_id = aws_vpc.VPC_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt1"
  }
}

resource "aws_route_table" "Prv_RT" {
  vpc_id = aws_vpc.VPC_1.id


  tags = {
    Name = "rt2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Pub_1.id
  route_table_id = aws_route_table.Pub_RT.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.Prv_2.id
  route_table_id = aws_route_table.Prv_RT.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.VPC_1.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

