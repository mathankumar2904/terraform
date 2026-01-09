provider "aws" {
  region = "us-east-1"
}

# Step 1: Create a new VPC
resource "aws_vpc" "poc_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-poc-vpc"
  }
}

# Step 2: Create a new Subnet in the VPC
resource "aws_subnet" "poc_subnet" {
  vpc_id                  = aws_vpc.poc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-poc-subnet"
  }
}

# Step 3: Create an Internet Gateway
resource "aws_internet_gateway" "poc_igw" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = {
    Name = "terraform-poc-igw"
  }
}

# Step 4: Create a Route Table
resource "aws_route_table" "poc_route" {
  vpc_id = aws_vpc.poc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc_igw.id
  }

  tags = {
    Name = "terraform-poc-rt"
  }
}

# Step 5: Associate Route Table with Subnet
resource "aws_route_table_association" "poc_assoc" {
  subnet_id      = aws_subnet.poc_subnet.id
  route_table_id = aws_route_table.poc_route.id
}

# Step 6: Create a Security Group
resource "aws_security_group" "poc_sg" {
  name   = "terraform-poc-sg"
  vpc_id = aws_vpc.poc_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "terraform-poc-sg"
  }
}

# Step 7: Launch EC2 Instance in the new Subnet
resource "aws_instance" "foo" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.poc_subnet.id
  vpc_security_group_ids = [aws_security_group.poc_sg.id]
  key_name               = "test-vpc-2-key"

  tags = {
    Name = "TerraformPOCInstance"
  }

  # Ensure EC2 waits until subnet and SG are created
  depends_on = [
    aws_subnet.poc_subnet,
    aws_security_group.poc_sg,
    aws_route_table_association.poc_assoc
  ]
}
