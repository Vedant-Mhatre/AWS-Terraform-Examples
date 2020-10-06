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


  # provisioner "file" {
  #   source      = "/home/vedant/myKP.pem"
  #   destination = "/home/myKP.pem"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/media/vedant/9144abc5-9ffa-47d3-bba8-29c11c792c29/home/vedant/Github/Terraform/git-S3-cloudfront/myKP.pem")
    host        = aws_instance.public-web-ec2.public_ip
  }


  tags = {
    Name = "Dev-Web"
  }

  depends_on = [
    aws_security_group.allow-web_traffic-1,
    aws_subnet.subnet-1
  ]
}

output "server_public_ip" {
  value = aws_instance.public-web-ec2.public_ip
}