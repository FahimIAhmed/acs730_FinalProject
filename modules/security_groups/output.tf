output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
  description="security group id of bastion"
}

output "private_sg" {
  value = aws_security_group.private_sg.id
  description="security group id of bastion"
}
