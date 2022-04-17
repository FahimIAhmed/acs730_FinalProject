# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Provision SSH key pair for Linux VMs
resource "aws_key_pair" "launch_key" {
  key_name   = "launch_key"
  public_key = file(var.path_to_key)
    # tags = merge({
    # Name = "${local.name_prefix}-keypair"
    # },
    # local.default_tags
  # )
}

# # Use remote state to retrieve the data
# # Data source for AMI id
# data "aws_ami" "latest_amazon_linux" {
#   owners      = ["amazon"]
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }


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


## Use remote state to retrieve the data
#data "terraform_remote_state" "network" {
#  backend = "s3"
#  config = {
#    bucket = "group-8-project1"              // Bucket where to SAVE Terraform State
#    key    = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
#    region = "us-east-1"                     // Region where bucket is created
#  }
#}
#


# # Retrieve global variables from the Terraform module
# module "globalvars" {
#   source = "../../modules/globalvars"
# }


#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix     = "webserver-launch-config"
  image_id        =  data.aws_ami.ami-amzn2.id
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
  #force_delete         = true
  #depends_on           = [aws_lb.ALB-tf]
  #target_group_arns    = ["${aws_lb_target_group.TG-tf.arn}"]
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  #vpc_zone_identifier  = ["${aws_subnet.prv_sub1.id}", "${aws_subnet.prv_sub2.id}"]
  vpc_zone_identifier  = var.vpc_zone_identifier

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-autoscaling-group"
      propagate_at_launch = true
    }
  )
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




# # Create Target group

# resource "aws_lb_target_group" "TG-tf" {
#   name       = "acs730-TargetGroup-tf"
#   depends_on = [aws_vpc.main]
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = aws_vpc.main.id
#   health_check {
#     interval            = 70
#     path                = "/index.html"
#     port                = 80
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 60
#     protocol            = "HTTP"
#     matcher             = "200,202"
#   }
# }

# # Create ALB

# resource "aws_lb" "ALB-tf" {
#   name               = "acs730-ALG-tf"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.elb_sg.id]
#   subnets            = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]

#   tags = {
#     name    = "acs730-AppLoadBalancer-tf"
#     Project = "acs730-assignment"
#   }
# }

# # Create ALB Listener 

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.ALB-tf.arn
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.TG-tf.arn
#   }
# }

