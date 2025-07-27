
terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
  }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my basic vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id 
  tags = {
    Name = "my-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id 
  cidr_block = var.public_subnet_cidr 
  map_public_ip_on_launch = true 
  availability_zone = "eu-central-1a"

tags = {
  Name = "my-public-subnet"
}
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public.id 
  route_table_id =aws_route_table.public.id  
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id 
  cidr_block = var.private_subnet_cidr 
  availability_zone = "eu-central-1a"

  tags = {
    Name = "my-private-subnet"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id 
  # only local routing is enabled by defauly. 
  tags = {
    Name = "private-route-table"
  }
}

# Associate private subnet with private route table 
resource "aws_route_table_association" "private_assoc" {
  subnet_id = aws_subnet.private.id 
  route_table_id = aws_route_table.private.id 
}

# creating ec2 instances, we need secuirty group ,keypair(download from aws console)

# secuirty group (Allow SSH from your IP)
resource "aws_security_group" "ssh_access" {
 name = "allow-ssh"
 description = "Allow ssh access"
 vpc_id = aws_vpc.main.id 

 ingress {
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["machine ip/32"] # 
 }

 
 ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from anywhere (for testing)
}


 egress  {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
 
   tags = {
    Name = "allow-ssh"
  }
}

# EC2 in public subnet 
resource "aws_instance" "public_ec2" {
  ami = "ami-02003f9f0fde924ea"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id 
  vpc_security_group_ids = [aws_security_group.ssh_access.id]
  key_name = "login"
  associate_public_ip_address = true 

  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install nginx -y
            sudo systemctl start nginx
            sudo systemctl enable nginx
            EOF
              
  tags = {
    Name = "Public-EC2"
  }
}

# EC2 in private subnet
resource "aws_instance" "private_ec2" {
  ami = "ami-02003f9f0fde924ea"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private.id 
   vpc_security_group_ids = [aws_security_group.ssh_access.id]
  key_name               = "login"
  associate_public_ip_address = false

   tags = {
    Name = "Private-EC2"
  }
}