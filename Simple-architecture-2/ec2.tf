resource "aws_instance" "web-1" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  # availability_zone           = "ap-south-1a"
  key_name                    = "myKP"
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = ["${aws_security_group.allow-web_traffic-1.id}"]
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Your first server > /var/www/html/index.html'
                EOF

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/vedant/Desktop/github/Terraform/git-S3-cloudfront/myKP.pem")
    host        = aws_instance.public-web-ec2.public_ip
  }


  tags = {
    Name = "Dev-Web-1"
  }

}

output "1st-instance-ip" {
  value = aws_instance.public-web-1.public_ip
}


# 2nd instance:
resource "aws_instance" "web-2" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  # availability_zone           = "ap-south-1a"
  key_name                    = "myKP"
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = ["${aws_security_group.allow-web_traffic-1.id}"]
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Your second server > /var/www/html/index.html'
                EOF

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/vedant/Desktop/github/Terraform/git-S3-cloudfront/myKP.pem")
    host        = aws_instance.public-web-ec2.public_ip
  }


  tags = {
    Name = "Dev-Web-2"
  }

}

output "2nd-instance-ip" {
  value = aws_instance.web-2.public_ip
}