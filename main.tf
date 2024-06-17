locals {
  Name = "ansible"
}

# VPC and Subnets
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "${local.Name}-vpc"
  }
}

resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2_1
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${local.Name}-subnet1"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2_2
  availability_zone = "eu-west-1b"
  tags = {
    Name = "${local.Name}-subnet2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.Name}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${local.Name}-rt"
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "${local.Name}-sg"
  description = "Allow inbound and outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }

  tags = {
    Name = "${local.Name}-sg"
  }
}

# Key Pair - Ensure unique name to avoid conflicts
resource "aws_key_pair" "key" {
  key_name   = "${local.Name}-key-${timestamp()}"
  public_key = file(var.path_to_keypair)
}

# Instances
resource "aws_instance" "ansible" {
  ami                         = var.ubuntu
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub1.id
  user_data                   = file("./userdata.sh")
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-ansible"
  }
}

resource "aws_instance" "redhat" {
  ami                         = var.redhat
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub2.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-redhat"
  }
}

resource "aws_instance" "ubuntu" {
  ami                         = var.ubuntu
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-ubuntu"
  }
}
