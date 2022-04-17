# Add output variables
output "lb_id" {
  description = "The ID and ARN of the load balancer"
  value       = concat(aws_lb.elb.*.id, [""])[0]
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = concat(aws_lb.elb.*.dns_name, [""])[0]
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer"
  value       = concat(aws_lb.elb.*.arn, [""])[0]
}

output "target_group_arns" {
  description = "ARNs of the target groups. for Auto Scaling group."
  value       = aws_lb_target_group.target_group.arn
}