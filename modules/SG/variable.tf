# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

variable "service_ports" {
  type        = list(string)
  default     = ["80", "22"]
  description = "Ports that should be open on a webserver"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.2.0.0/24","10.2.3.0/24", "10.2.4.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}
