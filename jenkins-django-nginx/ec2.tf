resource "aws_instance" "public-web-ec2" {
  ami                         = var.amis["ubuntu2004"]
  instance_type               = "t2.micro"
  availability_zone           = "ap-south-1a"
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_security_group.allow-web_traffic-1.id]
  key_name                    = "test-key"
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install git openjdk-11-jre -y
                wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
                sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
                /etc/apt/sources.list.d/jenkins.list'
                sudo apt update -y
                sudo apt install jenkins -y
                sudo systemctl enable --now jenkins
                sudo ufw allow 8080
                sudo sh -c 'echo "jenkins ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers'
                sudo apt install nginx -y
                sudo ufw allow 'Nginx HTTP'
                sudo snap install --classic certbot                
                EOF

  tags = {
    Project-Name = "test"
    Env          = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}



output "server_public_ip" {
  value = aws_instance.public-web-ec2.public_ip
}