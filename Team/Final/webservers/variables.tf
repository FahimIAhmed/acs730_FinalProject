# Instance type
variable "instance_type" {
  default = {
    "dev"    = "t3.micro"
  }
  description = "Type of the instance"
  type        = map(string)
}

# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Team"
    "App"   = "Web"
  }
  
# Prefix to identify resources
variable "prefix" {
  default     = "Final_Project"
  type        = string
  description = "Name prefix"
}


# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}