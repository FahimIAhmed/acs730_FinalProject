#  Define the provider
provider "aws" {
  region = "us-east-1"
}

#data source for availability zone
data "aws_availability_zones" "available" {
  state = "available"
}

# Use remote state to retrieve the data
# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}
# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "group8-dev"                    // Bucket where to SAVE Terraform State
    key    = "dev/network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                     // Region where bucket is created
  }
}

#ceating the ec2 instances
resource "aws_instance" "Group8-Dev" {
  count             = var.linux_VMs
  instance_type     = var.linux_instance_type
  ami               = data.aws_ami.latest_amazon_linux.id
  key_name          = aws_key_pair.dev_key.key_name
  availability_zone = data.aws_availability_zones.available.names[count.index]
  subnet_id         = data.terraform_remote_state.network.outputs.private_subnet_id[count.index]
  #security_groups             = [aws_security_group.private_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-NonProdVM${count.index}"
    }
  )
}



#creating bastion instance_tenancy
resource "aws_instance" "bastion_instance" {
  instance_type = var.bastion
  ami           = data.aws_ami.latest_amazon_linux.id
  key_name      = aws_key_pair.dev_key.key_name
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[1]
  #security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion"
    }
  )
}

# Provision SSH key pair for Linux VMs
resource "aws_key_pair" "dev_key" {
  key_name   = "id_rsa"
  public_key = file(var.path_to_publickey)
  tags = merge({
    Name = "${var.prefix}-keypair"
    },
    var.default_tags
  )
}

