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
                wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
                sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > \
                /etc/apt/sources.list.d/jenkins.list'
                sudo apt-get update -y
                sudo apt install jenkins -y
                sudo systemctl enable --now jenkins
                sudo ufw allow 8080
                sudo sh -c 'echo "jenkins ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers'
                sudo apt install nginx -y
                sudo ufw allow 'Nginx HTTP'
                sudo snap install --classic certbot
                sudo apt-get install python3-pip python3-dev libpq-dev libmysqlclient-dev -y
                sudo -H pip3 install --upgrade pip
                sudo -H pip3 install virtualenv
                sudo rm -f /var/www/html/*
                cd /var/www/html/ && sudo git clone -b ${var.branchname} https://${var.username}:${var.password}@gitlab.com/${var.reponame}
                cd *
                virtualenv env
                source env/bin/activate
                pip install django gunicorn
                pip install -r requirements.txt
                cd "$(dirname "$(find . -type f -name settings.py | head -1)")"'
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