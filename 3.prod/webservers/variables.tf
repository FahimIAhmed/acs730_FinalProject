# Instance type
variable "instance_type" {
  default = {

    "staging" = "t3.small"
    "prod"    = "t3.medium"
    "dev"     = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  type = map(string)
  default = {
    "Owner" = "Group-8"
    "App"   = "WebApp"
  }
}

# Prefix to identify resources
variable "prefix" {
  type    = string
  default = "Group-8"
}


# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "dev"
}

variable "ec2_count" {
  type    = number
  default = "0"
}

# Public IP
variable "my_public_ip" {
  type        = string
  description = "Cloud9 Public IP "
  default     = "3.236.246.143"
}

#  Private IP of cloud
variable "my_private_ip" {
  type        = string
  description = "Cloud Private IP "
  default     = "172.31.71.84"
}

variable "desired_size" {
  type        = number
  description = "Desired size for ASG"
  default     = 3
}

variable "max_size" {
  type        = number
  description = "Maximum size for ASG"
  default     = 3
}


variable "path_to_key" {
  default     = "/home/ec2-user/.ssh/dev_key.pub"
  description = "Path to the public key to use in Linux VMs provisioning"
  type        = string
}

