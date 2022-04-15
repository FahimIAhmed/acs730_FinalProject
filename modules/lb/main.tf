# #  Define the provider
# provider "aws" {
#   region = "us-east-1"
# }


# # Data source for availability zones in us-east-1
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# # Define tags locally
# locals {
#   default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
#   prefix       = module.globalvars.prefix
#   name_prefix  = "${local.prefix}-${var.env}"
# }


# # Retrieve global variables from the Terraform module
# module "globalvars" {
#   source = "../../modules/globalvars"
# }


# resource "aws_lb" "load_balancer" {
#   name               = "test-lb-tf"
#   internal           = false
#   load_balancer_type = "application"
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   #security_groups    = [aws_security_group.web_sg.id]
#  #security_groups = data.terraform_remote_state.network.outputs.web_sg.id
#  # subnets            = data.aws_availability_zones.available.names[count.index]
#   subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

#   enable_deletion_protection = true

# # data "terraform_remote_state" "network" { // This is to use Outputs from Remote State
# #   backend = "s3"
# #   config = {
# #     bucket = "team-final-project"      // Bucket from where to GET Terraform State
# #   # key    = "${var.env}-network/terraform.tfstate" 
# #     key = "Network/terraform.tfstate"
# #     // Object name in the bucket to GET Terraform State
# #     region = "us-east-1"                            // Region where bucket created
# #   }
# # }

#   access_logs {
#     bucket  = "team-final-project" 
#     #prefix  = "test-lb"
#     enabled = true
#   }

# tags = merge(local.default_tags,
#     {
#       "Name" = "${local.name_prefix}-lb"
#     }
#   )
# }
