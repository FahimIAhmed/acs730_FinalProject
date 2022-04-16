# Define the provider
provider "aws" {
  region = "us-east-1"
}

#data source for availability zone
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}
# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "group-8-project1"                   // Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     // Region where bucket is created
  }
}

# Provision SSH key pair for Linux VMs
resource "aws_key_pair" "dev_key" {
  key_name   = "dev_key"
  public_key = file(var.path_to_publickey)
  tags = merge({
    Name = "${var.prefix}-keypair"
    },
    var.default_tags
  )
}

# Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "autoscale_launchconfig" {
  name                        = "LaunchConf"
  image_id                    = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.linux_instance_type
  key_name                    = aws_key_pair.dev_key.key_name
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

# Creating the autoscaling group across 3 availability zones
resource "aws_autoscaling_group" "autoscaling_group" {
  vpc_zone_identifier                    = data.terraform_remote_state.network.outputs.public_subnet_ids
  #availability_zones        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  name                      = "autoscaling_group"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  #termination_policies      = ["Default"]
  launch_configuration      = aws_launch_configuration.autoscale_launchconfig.name
  lifecycle {
    create_before_destroy = true
      }


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

resource "aws_autoscaling_attachment" "asg_attachment" {
  
  lb_target_group_arn = aws_lb_target_group.tg-1.arn
 autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
 }
  

# Creating the autoscaling scale out policy
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                  = "scale_out_policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# Creating the AWS CLoudwatch Alarm that will scale out the AWS EC2 instance based on CPU utilization
resource "aws_cloudwatch_metric_alarm" "alarm_cpu_scale_out" {
  alarm_name          = "alarm_cpu_scale_out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_actions = [
    "${aws_autoscaling_policy.scale_out_policy.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling_group.name}"
  }
}

# Creating the autoscaling scale in policy
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale_in_policy"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

# Creating the AWS CLoudwatch Alarm that will scale in the AWS EC2 instance based on CPU utilization
resource "aws_cloudwatch_metric_alarm" "alarm_cpu_scale_in" {
  alarm_name          = "alarm_cpu_scale_in"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"
  alarm_actions = [
    "${aws_autoscaling_policy.scale_in_policy.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling_group.name}"
  }
}




resource "aws_lb_target_group" "tg-1" {
  name                          = "lb-tg-1"
  port                          = 80
  protocol                      = "HTTP"
  #target_type                   = "ip"
  vpc_id                        = data.terraform_remote_state.network.outputs.vpc_id
  #load_balancing_algorithm_type = "round_robin"
  # deregistration_delay          = 60
  # stickiness {
  #   enabled         = false
  #   type            = "lb_cookie"
  #   cookie_duration = 60
  # }

  # health_check {
  #   healthy_threshold   = 2
  #   unhealthy_threshold = 2
  #   interval            = 300
  #   path                = "/"
  #   protocol            = "HTTP"
  #   matcher             = 200
  # }

  # lifecycle {
  #   create_before_destroy = true
  # }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-target-group"
    }
  )
}

resource "aws_lb" "appln-lb" {
  name                       = "appln-lb"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  security_groups            = [aws_security_group.lb_sg.id]
  subnets                    = data.terraform_remote_state.network.outputs.public_subnet_ids
  enable_deletion_protection = false
  #depends_on                 = [aws_lb_target_group.tg-1]
  tags = {
    Name = "${var.prefix}-appln-lb"
  }
}


resource "aws_lb_listener" "listner" {

  load_balancer_arn = aws_lb.appln-lb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-1.arn
    # fixed_response {
    #   content_type = "text/plain"
    #   message_body = " Site Not Found"
    #   status_code  = "200"
    # }
  }

  
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-listner"
    }
  )
}


# resource "aws_alb_target_group_attachment" "Instance1" {
#   target_group_arn = aws_lb_target_group.tg-1.arn
#   target_id = aws_instance.Group8-Dev[0].private_ip
# }


# resource "aws_alb_target_group_attachment" "Instance2" {
#   target_group_arn = aws_lb_target_group.tg-1.arn
# target_id = aws_instance.Group8-Dev[1].private_ip
# }


# resource "aws_alb_target_group_attachment" "Instance3" {
# target_group_arn = aws_lb_target_group.tg-1.arn
# target_id = aws_instance.Group8-Dev[2].private_ip
# }


# resource "aws_lb_listener_rule" "rule-1" {

#   listener_arn = aws_lb_listener.listner.id
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg-1.arn
#   }

#   condition {
#     host_header {
#       values = ["version1.anandg.xyz"]
#     }
#   }
#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-Bastion"
#     }
#   )
# }


resource "aws_security_group" "lb_sg" {

name        = "allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    #cidr_blocks = ["${data.terraform_remote_state.network.outputs.public_cidr_blocks[1]}"]
     cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
  }


# ingress {
#     description = "HTTP from everywhere"
#     from_port   = 8088
#     to_port     = 8088
#     protocol    = "tcp"
#     #cidr_blocks = ["${data.terraform_remote_state.network.outputs.public_cidr_blocks[1]}"]
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-lb-sg"
    }
  )
}
  