
output "bastion-public_ip" {
  value = aws_instance.bastion_instance.public_ip
}

output "VM-private_ip" {
  value = aws_instance.Group8-Dev[*].private_ip
}

output "bastion_sg" {
  value       = aws_security_group.bastion_sg.id
  description = "security group id of bastion"
}

output "private_sg" {
  value       = aws_security_group.private_sg.id
  description = "security group id of bastion"
}

output "alb-endpoint" {
  value = aws_lb.appln-lb.dns_name
}
