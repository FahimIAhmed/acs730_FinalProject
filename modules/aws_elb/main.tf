# Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Use remote state to retrieve the data
data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "group-8-project-prod-fa"                // Bucket from where to GET Terraform State
    key    = "prod/network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                         // Region where bucket created
  }
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
  prefix      = var.prefix
  name_prefix = "${var.prefix}-${var.env}"
}

# LB resource
resource "aws_lb" "elb" {
  name               = "elb-${var.env}"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-ELB"
    }
  )
}

#Load Balance Listener
resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.elb.arn
  protocol          = "HTTP"
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

#LB target group
resource "aws_lb_target_group" "target_group" {
  name     = "target-elb-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "target-elb-${var.env}",
  Env = var.env 
  }
}

