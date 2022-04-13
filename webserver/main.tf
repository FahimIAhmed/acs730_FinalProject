module "web-mod" {
  source              = "../modules/aws_webserver"
  env                 = var.env
  private_cidr_blocks = var.private_cidr_blocks
  public_cidr_blocks  = var.public_cidr_blocks
  prefix              = var.prefix
  default_tags        = var.default_tags
}

module "sec-gp" {
  source       = "../modules/security_groups"
  env          = var.env
  prefix       = var.prefix
  default_tags = var.default_tags
}