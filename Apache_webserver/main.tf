provider "aws" {
  region     = "ap-south-1"
  access_key = Your access_key
  secret_key = Your secret_key
}
#example:
#access_key = "abcd"
#secret_key = "abcdefgh"


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
    Name = "dev-subnet"
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
    description = "HTTPS traffic from VPC"
    from_port   = 443
    to_port     = 443
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

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-nw.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "dev-web-ec2" {
  ami           = "ami-0cda377a1b884a1bc"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "myKP"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.dev-nw.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Your first server > /var/www/html/index.html'
                EOF

  tags = {
    Name = "Dev-Web"
  }
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

