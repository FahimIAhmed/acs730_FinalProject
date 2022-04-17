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
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}
#variable for public cidr block
variable "public_cidr_blocks" {
  default     = ["10.100.1.0/24", "10.100.2.0/24", "10.100.0.0/24"]
  description = "private cidrs"
  type        = list(string)
}
#variable for private cidr block
variable "private_cidr_blocks" {
  default     = ["10.100.3.0/24", "10.100.4.0/24", "10.100.5.0/24"]
  description = "private cidrs"
  type        = list(string)
}

#variable for vpc
variable "vpc_cidr" {
  description = "aws vpc"
  type        = string
}
