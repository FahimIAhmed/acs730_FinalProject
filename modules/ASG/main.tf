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
    bucket = "dev-group-8"                    // Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     // Region where bucket is created
  }
}

# Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "autoscale_launchconfig" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = var.linux_instance_type
  key_name = aws_key_pair.dev_key.key_name
  security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-LaunchConf${count.index}"
    }
  )
}

# Creating the autoscaling group across 3 availability zones
resource "aws_autoscaling_group" "autoscaling_group" {
  availability_zone = data.aws_availability_zones.available.names[count.index]
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "EC2"
  termination_policies      = ["Default"]
  launch_configuration      = aws_launch_configuration.autoscale_launchconfig.name
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-AutoScalingGroup${count.index}"
    }
  )
}


  