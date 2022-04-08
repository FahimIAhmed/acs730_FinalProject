# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Team",
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "Project"
  description = "Name prefix"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.2.0.0/24", "10.2.3.0/24", "10.2.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidrs" {
  default     = ["10.2.5.0/24", "10.2.6.0/24", "10.2.7.0/24"]
  type        = list(string)
  description = "Private Subnet CIDR"
}

# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.2.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

