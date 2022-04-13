
output "bastion-public_ip" {
  value = aws_instance.bastion_instance.public_ip
}
output "VM-private_ip" {
  value = aws_instance.Group8-Dev[*].private_ip
}

output "alb-endpoint" {
  value = aws_lb.appln-lb.dns_name
}