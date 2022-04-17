# Add output variables
output "public_subnet_ids" {
  value = module.network-dev.public_subnet_ids
}

output "private_subnet_id" {
  value = module.network-dev.private_subnet_id
}

output "vpc_id" {
  value = module.network-dev.vpc_id
}

output "public_cidr_blocks" {
  value = module.network-dev.public_cidr_blocks
}

output "private_cidr_blocks" {
  value = module.network-dev.private_cidr_blocks
}


output "private_route_table" {
  value = module.network-dev.private_route_table
}

output "public_route_table" {
  value = module.network-dev.public_route_table
}

output "prod_vpc_cidr" {
  value = module.network-dev.prod_vpc_cidr
}
