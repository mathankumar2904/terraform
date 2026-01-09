provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "foo" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  subnet_id     = "subnet-071467d125ce00f81"  # Replace with your subnet ID

  tags = {
    Name = "MyInstance"
  }
}

