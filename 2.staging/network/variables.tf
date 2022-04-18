# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

#prefix variable for the resources
variable "prefix" {
  default     = "Group-8-Project"
  description = "prefix for resources"
  type        = string
}
# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}
#variable for public cidr block
variable "public_cidr_blocks" {
  default     = ["10.200.1.0/24", "10.200.2.0/24", "10.200.0.0/24"]
  description = "private cidrs"
  type        = list(string)
}
#variable for private cidr block
variable "private_cidr_blocks" {
  default     = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
  description = "private cidrs"
  type        = list(string)
}

#variable for vpc
variable "vpc_cidr" {
  default     = "10.200.0.0/16"
  description = "aws vpc "
  type        = string
}
