variable "num_linux_vms" {
  default     = 2
  description = "Number of Linux VMs to provision"
  type        = number
}

#for creating the instances of same type
variable "linux_instance_type" {
  default     = "t3.micro"
  description = "Instance type to use"
  type        = string
}

#path to key for the instances 
variable "path_to_publickey" {
  default     = "/home/ec2-user/.ssh/dev_key.pub"
  description = "Path to the public key to use in Linux VMs provisioning"
  type        = string
}

#default_tags variable
variable "default_tags" {
  default = {
    "Owner" = "Group8"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
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
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "private cidrs"
  type        = list(string)
}
#variable for private cidr block
variable "private_cidr_blocks" {
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
  description = "private cidrs"
  type        = list(string)
}
