output "public_subnet_ids" {
  value = module.vpc-dev.public_subnet_ids
}

output "private_subnet_id" {
  value = module.vpc-dev.private_subnet_id
}

output "vpc_id" {
  value = module.vpc-dev.vpc_id
}

output "private_cidr_blocks" {
  value = module.vpc-dev.private_cidr_block
}

output "public_cidr_blocks" {
  value = module.vpc-dev.public_cidr_blocks
}

# Step 10 - Add output variables
output "web_sg" {
  value = module.SG.web_sg
}