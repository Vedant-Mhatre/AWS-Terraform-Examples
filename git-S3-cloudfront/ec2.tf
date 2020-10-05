resource "aws_instance" "public-web-ec2" {
  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "myKP"
  security_groups  = ["allow-web"]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                git clone https://github.com/beashaj2001/beashaj1.git /var/www/html/
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