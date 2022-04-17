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
  default     = "10.100.0.0/16"
  description = "aws vpc "
  type        = string
}
#Key path
variable "path_to_key" {
  default     = "/home/ec2-user/.ssh/acs730key.pub"
  description = "Path to the public key to use in Launch Configuration"
  type        = string
}



variable "region" {
  type        = string
  default     = "us-east-1"
  description = "default region"
}


variable "sg_name" {
  type    = string
  default = "alb_sg"
}

variable "sg_description" {
  type    = string
  default = "SG for application load balancer"
}

variable "sg_tagname" {
  type    = string
  default = "SG for ALB"
}

variable "sg_ws_name" {
  type    = string
  default = "webserver_sg"
}

variable "sg_ws_description" {
  type    = string
  default = "SG for web server"
}

variable "sg_ws_tagname" {
  type    = string
  default = "SG for web"
}
