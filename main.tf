provider "aws" {
  region = "us-east-1"
}

############################
# Step 1: Create VPC
############################
resource "aws_vpc" "poc_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-poc-vpc"
  }
}

############################
# Step 2: Create Subnet
############################
resource "aws_subnet" "poc_subnet" {
  vpc_id            = aws_vpc.poc_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform-poc-subnet"
  }
}

############################
# Step 3: Create Security Group
############################
resource "aws_security_group" "poc_sg" {
  name   = "terraform-poc-sg"
  vpc_id = aws_vpc.poc_vpc.id

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

############################
# Step 4: Create EC2 Instance
############################
resource "aws_instance" "foo" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.poc_subnet.id
  vpc_security_group_ids = [aws_security_group.poc_sg.id]
  key_name               = "test-vpc-2-key"  # replace with your keypair

  tags = {
    Name = "TerraformPOCInstance"
  }

  # Ensure subnet & SG exist before creating EC2
  depends_on = [
    aws_subnet.poc_subnet,
    aws_security_group.poc_sg
  ]
}

############################
# Step 5: Output Subnet ID
############################
output "subnet_id" {
  value = aws_subnet.poc_subnet.id
}
