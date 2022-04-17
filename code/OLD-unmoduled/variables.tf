variable "ami" {
  type    = string
  default = "ami-010aff33ed5991201"
}
variable "keyname" {
  default = "acs730key"
}
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "default region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.100.0.0/16"
  description = "default vpc_cidr_block"
}

variable "pub_sub1_cidr_block" {
  type    = string
  default = "10.100.1.0/24"
}
variable "pub_sub2_cidr_block" {
  type    = string
  default = "10.100.2.0/24"
}

variable "prv_sub1_cidr_block" {
  type    = string
  default = "10.100.3.0/24"
}
variable "prv_sub2_cidr_block" {
  type    = string
  default = "10.100.4.0/24"
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

variable "path_to_key" {
  default     = "/home/ec2-user/.ssh/acs730key.pub"
  description = "Path to the public key to use in Launch Configuration"
  type        = string
}
