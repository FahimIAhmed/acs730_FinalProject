# Add output variables
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "lb_dns_name" {
  description = "The DNS of elastic load balancer."
  value       = module.aws_elb.lb_dns_name
}

