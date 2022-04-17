# Add output variables
output "public_subnet_ids" {
  value = aws_subnet.pub_sub[*].id
}

output "private_subnet_id" {
  value = aws_subnet.prv_sub[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_cidr_blocks" {
  value = aws_subnet.pub_sub[*].cidr_block
}

output "private_cidr_blocks" {
  value = aws_subnet.prv_sub[*].cidr_block
}


output "private_route_table" {
  value = aws_route_table.pub_sub_rt[*].id
}

output "public_route_table" {
  value = aws_route_table.pub_sub_rt[*].id
}

output "prod_vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
