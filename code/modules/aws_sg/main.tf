# module "network" {
#   source = "../aws_network"
# # base_cidr_block = "10.0.0.0/8"
# }

# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
backend = "s3"
config = {
  bucket = "group-8-project-fa" // Bucket where to SAVE Terraform State
  key = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
  region = "us-east-1" // Region where bucket is created
  }
}

resource "aws_security_group" "elb_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = var.sg_tagname
    Project = "acs730-assignment"
  }
}

# Create security group for webserver

resource "aws_security_group" "webserver_sg" {
  name        = var.sg_ws_name
  description = var.sg_ws_description
  #vpc_id      = aws_vpc.main.id
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = var.sg_ws_tagname
    Project = "acs730-assignment"
  }
}
