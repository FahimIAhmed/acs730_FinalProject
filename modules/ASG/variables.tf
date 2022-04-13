#for creating the instances of same type
variable "linux_instance_type" {
  default     = "t3.micro"
  description = "Instance type to use"
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