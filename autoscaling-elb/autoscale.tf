resource "aws_launch_configuration" "webcluster" {
  image_id        = var.amis[var.region]
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow-web_traffic-1.id}"]
  key_name        = "myKP"
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Hello World > /var/www/html/index.html'
                EOF

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "allzones" {}

resource "aws_autoscaling_group" "scalegroup" {
  name                 = "scalegroup"
  launch_configuration = aws_launch_configuration.webcluster.name
  vpc_zone_identifier = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id, aws_subnet.subnet-3.id]
  min_size            = 2
  max_size            = 4
  enabled_metrics     = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]
  load_balancers      = ["${aws_elb.frontend.id}"]
  health_check_type   = "ELB"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_policy" "autopolicy-up" {
  name                   = "scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}

resource "aws_cloudwatch_metric_alarm" "cpualarm" {
  alarm_name          = "scaleup-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scalegroup.name
  }

  alarm_description = "Scaleup when CPU utilization greater than 80%"
  alarm_actions     = [aws_autoscaling_policy.autopolicy-up.arn]
}

resource "aws_autoscaling_policy" "autopolicy-down" {
  name                   = "scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name          = "scaledown-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.scalegroup.name
  }

  alarm_description = "Scale down when utilization less than 10%"
  alarm_actions     = [aws_autoscaling_policy.autopolicy-down.arn]
}