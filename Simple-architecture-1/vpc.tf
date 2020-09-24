resource "aws_vpc" "first-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id     = aws_vpc.first-vpc.id 
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id 
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id 
  }

  tags = {
    Name = "dev-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "allow-web" {
  name        = "allow-web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description = "HTTP traffic from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH traffic from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# ingress {
  #   description = "HTTPS traffic from VPC"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-web"
  }
}

resource "aws_network_interface" "dev-nw" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]
  # depends_on = [aws_instance.dev-web-ec2]

  # attachment {
  #   instance     = aws_instance.dev-web-ec2.id
  #   device_index = 1
  # }
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh_traffic"
  description = "Allow SSH inbound traffic from public subnet EC2 instance"
  vpc_id      = aws_vpc.first-vpc.id
  
  ingress {
    description = "SSH traffic from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet-1.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}

resource "aws_eip" "eip1" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  depends_on = [
    aws_internet_gateway.gw,
    aws_eip.eip1,
    aws_subnet.subnet-1,
  ]
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.subnet-1.id
}

resource "aws_route_table" "p" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id 
  }


  tags = {
    Name = "nat-route-table"
  }
}

resource "aws_route_table_association" "b" {
  depends_on = [
    aws_subnet.subnet-2,
    aws_route_table.p
  ]
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.p.id
}


