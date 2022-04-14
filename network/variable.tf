# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Team",
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

#prefix variable for the resources
variable "prefix" {
  default     = "Group-8-Project"
  description = "prefix for resources"
  type        = string
}

variable "public_cidr_blocks" {
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.0.0/24"]
  description = "private cidrs"
  type        = list(string)
}
#variable for private cidr block
variable "private_cidr_blocks" {
  default     = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  description = "private cidrs"
  type        = list(string)
}
# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

#variable for vpc
variable "vpc_id" {
  default     = "10.2.0.0/16"
  description = "aws vpc"
  type        = string
}


