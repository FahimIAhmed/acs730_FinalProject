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
    bucket = "dev-group-8"                   // Bucket where to SAVE Terraform State
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
  availability_zones        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  name                      = "autoscaling_group"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "EC2"
  termination_policies      = ["Default"]
  launch_configuration      = aws_launch_configuration.autoscale_launchconfig.name

  lifecycle {
    create_before_destroy = true
  }
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
    "${aws_autoscaling_policy.scale_out_policy.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.autoscaling_group.name}"
  }
}


  