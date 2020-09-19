provider "aws" {
  region     = "ap-south-1"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# this resource will create a key pair using above private key
resource "aws_key_pair" "key_pair" {
  key_name   = "myKP"
  public_key = tls_private_key.private_key.public_key_openssh

   depends_on = [tls_private_key.private_key]
}

# this resource will save the private key at our specified path.
resource "local_file" "saveKey" {
  content = tls_private_key.private_key.private_key_pem
  filename = "/home/vedant/myKP.pem"
  
}



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

  # ingress {
  #   description = "HTTPS traffic from VPC"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
  # depends_on = [aws_instance.dev-web-ec2]

  # attachment {
  #   instance     = aws_instance.dev-web-ec2.id
  #   device_index = 1
  # }
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-nw.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "public-web-ec2" {
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


  provisioner "file" {
    source      = "/home/vedant/myKP.pem"
    destination = "/home/myKP.pem"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.private_key.private_key_pem
    host     = aws_instance.public-web-ec2.public_ip
    }
  }

  tags = {
    Name = "Dev-Web"
  }
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


resource "aws_instance" "private-ec2" {
  depends_on = [
    aws_security_group.allow-ssh,
    aws_subnet.subnet-2,

  ]
  ami           = "ami-0cda377a1b884a1bc"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  subnet_id = aws_subnet.subnet-2.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  key_name = "myKP"


  
  tags = {
    Name = "Private-Server"
  }
}


output "server_public_ip" {
  value = aws_eip.one.public_ip
}





# basic syntax
# resource "<provider>_<resource_type_name>" "name"{
#     key = "value"
# }

# resource "aws_instance" "web" {
#   ami           = "ami-09a7bbd08886aafdf"
#   instance_type = "t2.micro"
#   tags = {
#       Name = "temporary-web-server"
#   }

# }