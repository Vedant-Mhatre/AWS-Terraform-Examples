provider "aws" {
  region     = var.region
}

# resource "tls_private_key" "private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # this resource will create a key pair using above private key
# resource "aws_key_pair" "key_pair" {
#   key_name   = "myKP"
#   public_key = tls_private_key.private_key.public_key_openssh

#    depends_on = [tls_private_key.private_key]
# }

# # this resource will save the private key at our specified path.
# resource "local_file" "saveKey" {
#   content = tls_private_key.private_key.private_key_pem
#   filename = "/home/vedant/myKP.pem"
  
# }




resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-nw.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_instance" "public-web-ec2" {
  ami           = var.amis[var.region]
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


  # provisioner "file" {
  #   source      = "/home/vedant/myKP.pem"
  #   destination = "/home/myKP.pem"

  #   connection {
  #   type     = "ssh"
  #   user     = "ubuntu"
  #   private_key = tls_private_key.private_key.private_key_pem
  #   host     = aws_instance.public-web-ec2.public_ip
  #   }
  # }

  tags = {
    Name = "Dev-Web"
  }
}



resource "aws_instance" "private-ec2" {
  depends_on = [
    aws_security_group.allow-ssh,
    aws_subnet.subnet-2,

  ]
  ami           = var.amis[var.region]
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