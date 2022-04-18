# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami-amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix     = "webserver-launch-config"
  image_id        = data.aws_ami.ami-amzn2.id
  instance_type   = lookup(var.instance_size, var.env)
  key_name        = var.launch_key
  security_groups = var.security_groups
  #security_groups = ["${aws_security_group.webserver_sg.id}"]

  associate_public_ip_address = true

  user_data = filebase64("${path.module}/init_webserver.sh")

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "ASG" {
  name                 = "Group8-ASG-${var.env}"
  desired_capacity     = var.asg_target_size
  min_size             = 1
  max_size             = var.asg_max_size
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier  = var.vpc_zone_identifier

  tag {
    key = "Name"
    value = "${local.name_prefix}-asg-instances"
    propagate_at_launch = true
    }
  
  dynamic "tag" {
    for_each = local.default_tags
    content {
    key = tag.key
    value = tag. value
    propagate_at_launch = true
    }
  }
}



# Create autoscaling attachment
resource "aws_autoscaling_attachment" "ASG_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG.id
  lb_target_group_arn    = var.lb_target_group_arn
}

# Create auto-scaling policy for scaling in
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale_in_policy"
  autoscaling_group_name = aws_autoscaling_group.ASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 900
}

resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  alarm_name          = "web_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "5"
  evaluation_periods  = "2"
  period              = "600"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG.name
  }
}

# Create auto-scaling policy for scaling out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "web_scale_out"
  autoscaling_group_name = aws_autoscaling_group.ASG.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

# Create cloud watch alarm to scale out if cpu util if the load is above 10%
resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  alarm_name          = "web_scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG.name
  }
}

