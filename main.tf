provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example1" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
subnet_id = aws_subnet.customer_subnet1.id
vpc_security_group_ids = [aws_security_group.firewall_sg_subnet1.id]


  tags = {
    Name = "terraform_task2.1"
  }
}

resource "aws_instance" "example2" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
subnet_id = aws_subnet.customer_subnet2.id
vpc_security_group_ids = [aws_security_group.firewall_sg_subnet2.id]


  tags = {
    Name = "terraform_task2.2"
  }
}

// created VPC
resource "aws_vpc" "main_VPC" {
  cidr_block = "10.0.0.0/16"
}

// creating subnet

resource "aws_subnet" "customer_subnet1" {
  vpc_id     = aws_vpc.main_VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "cus_sub1"
  }
}


resource "aws_subnet" "customer_subnet2" {
  vpc_id     = aws_vpc.main_VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "cus_sub2"
  }
}

// create internet gateway

resource "aws_internet_gateway" "igw-1232" {
  vpc_id = aws_vpc.main_VPC.id

  tags = {
    Name = "igw"
  }
}

// creating routing table 

resource "aws_route_table" "vpc_rt" {
  vpc_id = aws_vpc.main_VPC.id

}


// add subnet to the route table

resource "aws_route_table_association" "rt_ass_subnet1" {
  subnet_id      = aws_subnet.customer_subnet1.id
  route_table_id = aws_route_table.vpc_rt.id
}

resource "aws_route_table_association" "rt_ass_subnet2" {
  subnet_id      = aws_subnet.customer_subnet2.id
  route_table_id = aws_route_table.vpc_rt.id
}


// create security group

resource "aws_security_group" "firewall_sg_subnet1" {
  name        = "firewall_sg_subnet1"
  vpc_id      = aws_vpc.main_VPC.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.4.0/28"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "firewall_sg_subnet1"
  }
}


resource "aws_security_group" "firewall_sg_subnet2" {
  name        = "firewall_sg_subnet2"
  vpc_id      = aws_vpc.main_VPC.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.4.16/28"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "firewall_sg_subnet2"
  }
}
