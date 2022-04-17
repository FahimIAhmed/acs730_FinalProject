# variable to hold the instance size
variable "instance_size" {
  description = "size of the instance"
  type        = map(string)
}

# Variable to hold the  environment 
variable "env" {
  type        = string
  description = "Deployment Environment"
}

variable "asg_target_size" {
  type        = number
  description = "target size for ASG"
}

variable "asg_max_size" {
  type        = number
  description = "Maximum size for ASG"
}

# Variable for list of private subnet ids for vpc_zone_identifier
variable "vpc_zone_identifier" {
  description = "A list of subnets"
  type        = list(string)
  default     = null
}

# Variable for LB Target Group ARN
variable "lb_target_group_arn" {
  description = "LB Target Group ARN"
  type        = string
  default     = null
}

# Variable for the security groups to attach to AWS Launch Configuration
variable "security_groups" {
  description = "Security group to attach to AWS Launch Configuration"
  type        = list(string)
  default     = []
}

# Variable to hold path to private key
variable "path_to_key" {
  description = "Path to the public key to use in Linux VMs provisioning"
  type        = string
  default     = "/home/ec2-user/.ssh/dev_key.pub"
}

# Default tags
variable "default_tags" {
  type        = map(string)
  description = "Default tags to be appliad to all AWS resources"
  default = {
    "Owner" = "Group-8"
    "App"   = "WebApp"
  }
}

# Variable for VPC_ID
variable "vpc" {
  description = "VPC id"
  type        = string
  default     = null
}

# Variable for SSH Key 
variable "launch_key" {
  description = "SSH Key"
  type        = string
  default     = null
}

# Variable for name prefix
variable "prefix" {
  type        = string
  description = "Name prefix"
}

