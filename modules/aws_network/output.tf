# Add output variables
output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_cidr_blocks" {
  value = aws_subnet.public_subnet[*].cidr_block
}

output "private_cidr_blocks" {
  value = aws_subnet.private_subnet[*].cidr_block
}

output "alb-endpoint" {
  value = aws_lb.appln-lb.dns_name
}