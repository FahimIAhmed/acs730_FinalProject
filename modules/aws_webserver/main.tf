#  Define the provider
provider "aws" {
  region = "us-east-1"
}

#data source for availability zone
data "aws_availability_zones" "available" {
  state = "available"
}

# Use remote state to retrieve the data
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

#ceating the ec2 instances
resource "aws_instance" "Group8-Dev" {
  count             = var.linux_VMs
  instance_type     = var.linux_instance_type
  ami               = data.aws_ami.latest_amazon_linux.id
  key_name          = aws_key_pair.dev_key.key_name
  availability_zone = data.aws_availability_zones.available.names[count.index]
  subnet_id         = data.terraform_remote_state.network.outputs.private_subnet_id[count.index]
  #security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-NonProdVM${count.index}"
    }
  )
}



#creating bastion instance_tenancy
resource "aws_instance" "bastion_instance" {
  instance_type = var.bastion
  ami           = data.aws_ami.latest_amazon_linux.id
  key_name      = aws_key_pair.dev_key.key_name
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  #security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion"
    }
  )
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


resource "aws_lb_target_group" "tg-1" {
  name                          = "lb-tg-1"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.terraform_remote_state.network.outputs.vpc_id
  load_balancing_algorithm_type = "round_robin"
  deregistration_delay          = 60
  stickiness {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = 60
    
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = 200

  }

  lifecycle {
    create_before_destroy = true
  }
  
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
  #security_groups            = data.terraform_remote_state.network.outputs.bastion_sg[1]
  subnets                    = data.terraform_remote_state.network.outputs.public_subnet_ids
  enable_deletion_protection = false
  depends_on                 = [aws_lb_target_group.tg-1]
  tags = {
    Name = "${var.prefix}-appln-lb"
  }
}



resource "aws_lb_listener" "listner" {

  load_balancer_arn = aws_lb.appln-lb.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = " Site Not Found"
      status_code  = "200"
    }
  }

  depends_on = [aws_lb.appln-lb]
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-listner"
    }
  )
}



resource "aws_lb_listener_rule" "rule-1" {

  listener_arn = aws_lb_listener.listner.id
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-1.arn
  }

  condition {
    host_header {
      values = ["version1.anandg.xyz"]
    }
  }
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion"
    }
  )
}






