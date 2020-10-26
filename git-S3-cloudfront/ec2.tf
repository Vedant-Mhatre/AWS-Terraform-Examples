resource "aws_instance" "public-web-ec2" {
  ami                         = var.amis[var.region]
  instance_type               = "t2.micro"
  availability_zone           = "ap-south-1a"
  key_name                    = "myKP"
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = ["${aws_security_group.allow-web_traffic-1.id}"]
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 git -y
                sudo rm -rf /var/www/html
                git clone https://github.com/Vedant-Mhatre/Sample-Html-Css-Website.git /var/www/html/
                sudo systemctl restart apache2
                EOF

  lifecycle {
    create_before_destroy = true
  }

  # provisioner "file" {
  #   source      = "/home/vedant/myKP.pem"
  #   destination = "/home/myKP.pem"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/vedant/Desktop/github/Terraform/git-S3-cloudfront/myKP.pem")
    host        = aws_instance.public-web-ec2.public_ip
  }


  tags = {
    Name = "Dev-Web"
  }

}

output "server_public_ip" {
  value = aws_instance.public-web-ec2.public_ip
}