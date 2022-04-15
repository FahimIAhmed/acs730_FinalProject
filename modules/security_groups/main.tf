#  Define the provider
provider "aws" {
  region = "us-east-1"
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
    bucket = "group-8-project"                    // Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     // Region where bucket is created
  }
}

# # Security Group
# resource "aws_security_group" "bastion_sg" {
#   name        = "BastionSG"
#   description = "Allow SSH inbound traffic"
#   vpc_id      = data.terraform_remote_state.network.outputs.vpc_id


#   ingress {
#     description      = "SSH from everywhere"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-bastion-sg"
#     }
#   )
# }

# resource "aws_security_group" "private_sg" {
#   name        = "Dev"
#   description = "Allow HTTP and SSH inbound traffic"
#   vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
#   ingress {
#     description = "HTTP from Bastion"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["${data.terraform_remote_state.network.outputs.public_cidr_blocks[1]}"]
#   }

#   ingress {
#     description = "SSH from Bastion"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["${data.terraform_remote_state.network.outputs.public_cidr_blocks[1]}"]
#   }


#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-private-vm-sg"
#     }
#   )
# }

# resource "aws_lb" "test" {
#   name               = "dev-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.bastion_sg.id]
#   #subnets            = [for subnet in aws_subnet.public_subnet_ids : subnet.id]

#   enable_deletion_protection = true

#   access_logs {
#     bucket  = "group8-dev"
#     prefix  = "Group8-Project"
#     enabled = true
#   }

#   tags = {
#     Environment = "dev"
#   }
# }