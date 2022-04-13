# terraform {
#   backend "s3" {
#     bucket               = "terraform-remote-states"
#     workspace_key_prefix = "environments"
#     key                  = "network"
#     region               = "us-east-1"
#   }
# }

# variable "network_cidr" {
#   type    = list(string)
#   default = {
#     dev     = "10.100.0.0/16"
#     staging = "10.200.0.0/16"
#     prod    = "10.300.0.0/16"
#   }
# }

# variable "private_subnet_cidrs" {
#   type = list(string)
#   default = {
#     dev     = ["10.100.0.0/24", "10.100.1.0/24", "10.100.2.0/24"]
#     staging = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
#     prod    = ["10.300.0.0/24", "10.300.1.0/24", "10.300.2.0/24"]
#   }
# }

# variable "public_subnet_cidrs" {
#   type = list(string)
#   default = {
#     dev     = ["10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/24"]
#     staging = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
#     prod    = ["10.300.3.0/24", "10.300.4.0/24", "10.300.5.0/24"]
#   }
# }

# locals {
#   network_cidr          = lookup(var.network_cidr, terraform.workspace, null)
#   private_subnet_cidrs  = lookup(var.private_subnet_cidrs, terraform.workspace, null)
#   public_subnet_cidrs   = lookup(var.public_subnet_cidrs, terraform.workspace, null)
# }

# module "network" {
#   source                = "../modules/network"
#   region                = "us-east-1"
#   network_cidr          = local.network_cidr
#   private_subnet_cidrs  = local.private_subnet_cidrs
#   public_subnet_cidrs   = local.public_subnet_cidrs
# }
