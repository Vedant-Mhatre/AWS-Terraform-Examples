resource "aws_elb" "frontend" {
  name = "elb-public-frontend"
  security_groups    = [aws_security_group.allow-web_traffic-1.id]
  subnets            = [aws_subnet.public_subnet-1.id, aws_subnet.public_subnet-2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }
}

output "elb-dns" {
  value = "${aws_elb.frontend.dns_name}"
}