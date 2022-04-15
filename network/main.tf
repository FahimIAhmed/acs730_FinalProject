
# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../modules/globalvars"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

# Module to deploy basic networking 
module "vpc-dev" {
  source = "../modules/aws_network"
  #source              = "git@github.com:igeiman/aws_network.git"
  env                 = var.env
  public_cidr_blocks  = var.public_cidr_blocks
  private_cidr_blocks = var.private_cidr_blocks
  prefix              = local.name_prefix
  default_tags        = local.default_tags
}

