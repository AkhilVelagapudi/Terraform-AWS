# Configure provider
provider "aws" {
  region     = "us-east-2" 
  access_key = "AKIA3FLD5EEIQSWOLMOU"
  secret_key = "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"
}

# Create VPC 
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  
  tags = {
    Name = "main-vpc"
  }
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                   = aws_vpc.main.id 
  cidr_block               = "10.0.1.0/24"
  map_public_ip_on_launch  = true
  availability_zone        = "us-east-2a"

  tags = {
    Name = "public-subnet" 
  }
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id 
  cidr_block        = "10.0.2.0/24" 
  availability_zone = "us-east-2a" 

  tags = {
    Name = "private-subnet" 
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id 

  tags = {
    Name = "main-igw" 
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id 

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.main.id 
  }

  tags = {
    Name = "public-rt" 
  }
}

# Connect public route table with public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id 
  route_table_id = aws_route_table.public.id 
}

# Create security group
resource "aws_security_group" "web_sg" {
  name        = "web-sg" 
  description = "Allow web traffic" 
  vpc_id      = aws_vpc.main.id 

  ingress {
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

  tags = {
    Name = "web-sg" 
  }
}

# Launch EC2 instance
resource "aws_instance" "web" {
  ami                  = "ami-033fabdd332044f06" # Amazon Linux 2023 AMI
  instance_type        = "t2.micro" 
  subnet_id            = aws_subnet.public.id 
  vpc_security_group_ids = [aws_security_group.web_sg.id] 

  tags = {
    Name = "web-server" 
  }
}

# Create EBS volume
resource "aws_ebs_volume" "web_volume" {
  availability_zone = "us-east-2a"
  size              = 10 # Size in GiB

  tags = {
    Name = "web-ebs-volume"
  }
}

# Attach EBS volume to the instance
resource "aws_volume_attachment" "web_volume_attachment" {
  device_name = "/dev/sdh" # The device name on the EC2 instance
  volume_id   = aws_ebs_volume.web_volume.id
  instance_id = aws_instance.web.id
}

# Create S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "data_bucket" 

  tags = {
    Name = "example-s3-bucket"
  }
}

# Output VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output public subnet ID
output "public_subnet_id" {
  value = aws_subnet.public.id
}

# Output EC2 instance ID
output "instance_id" {
  value = aws_instance.web.id
}

# Output public IP of the EC2 instance
output "public_ip" {
  value = aws_instance.web.public_ip
}

# Output S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}

# Output EBS volume ID
output "ebs_volume_id" {
  value = aws_ebs_volume.web_volume.id
}
