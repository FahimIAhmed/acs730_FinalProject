# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"
}


# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Project = "acs730-assignment"
    Name    = "My acs730 VPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "pub_sub" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}


# # Create Public Subnet2
# resource "aws_subnet" "pub_sub2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.pub_sub2_cidr_block
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true
#   tags = {
#     Project = "acs730-assignment"
#     Name    = "public_subnet2"
#   }
# }

# Create Private Subnet
resource "aws_subnet" "prv_sub" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index}"
      Tier = "Private"
    }
  )
}

# # Create Private Subnet2
# resource "aws_subnet" "prv_sub2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.prv_sub2_cidr_block
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = false

#   tags = {
#     Project = "acs730-assignment"
#     Name    = "private_subnet2"
#   }
# }

# Create Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-igw"
    }
  )
}

# Create Public Route Table

resource "aws_route_table" "pub_sub_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name_prefix}-public-route_table"
  }
}


# Create route table association of public subnet
resource "aws_route_table_association" "internet_for_pub_sub1" {
  count          = length(aws_subnet.pub_sub[*].id)
  route_table_id = aws_route_table.pub_sub_rt.id
  subnet_id      = aws_subnet.pub_sub[count.index].id
}


# Create EIP for NAT GW
resource "aws_eip" "eip_natgw" {
  count = "1"
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-${var.env}-eip"
    }
  )
}

# Create NAT gateway
resource "aws_nat_gateway" "natgateway" {
  count         = "1"
  allocation_id = aws_eip.eip_natgw[count.index].id
  subnet_id     = aws_subnet.pub_sub[0].id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-${var.env}-nat_gateway"
    }
  )
}


# Create private route table for prv sub

resource "aws_route_table" "prv_sub_rt" {
  count  = "1"
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway[count.index].id
  }
  tags = {
    Name = "${local.name_prefix}-public-route_table"
  }
}

# Create route table association between prv sub1 & NAT GW1

resource "aws_route_table_association" "pri_sub_to_natgw" {
  count = length(aws_subnet.prv_sub[*].id)
  #  count          = "1"
  route_table_id = aws_route_table.prv_sub_rt[0].id
  subnet_id      = aws_subnet.prv_sub[count.index].id
}



# # Create private route table for prv sub2

# resource "aws_route_table" "prv_sub2_rt" {
#   count  = "1"
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
#   }
#   tags = {
#     Project = "acs730-assignment"
#     Name    = "private subnet2 route table"
#   }
# }

# # Create route table association betn prv sub2 & NAT GW1

# resource "aws_route_table_association" "pri_sub2_to_natgw1" {
#   count          = "1"
#   route_table_id = aws_route_table.prv_sub2_rt[count.index].id
#   subnet_id      = aws_subnet.prv_sub2.id
# }


# Create security group for load balancer


# local variables
# locals {
#   default_tags = module.gloabl_vars.default_tags
#   name_prefix  = "${module.gloabl_vars.prefix}"
# }

