
# Module to deploy basic networking 
module "network-dev" {
  source = "../../modules/aws_network"
  #source              = "git@github.com:igeiman/aws_network.git"
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  private_cidr_blocks = var.private_cidr_blocks
  public_cidr_blocks  = var.public_cidr_blocks
  prefix              = var.prefix
  default_tags        = var.default_tags
  
  #public_subnet_ids   = aws_subnet.pub_sub


}


