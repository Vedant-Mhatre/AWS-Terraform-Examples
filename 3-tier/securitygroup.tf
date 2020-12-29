resource "aws_security_group" "allow-web_traffic-1" {
  name        = "allow-web_traffic-1"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description = "HTTP traffic from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "allow-web_traffic-1"
  }
}