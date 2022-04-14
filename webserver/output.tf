
output "bastion-public_ip" {
  description = "output for bastion public ip"
  value       = module.web-mod.bastion-public_ip
}
output "VM-private_ip" {
  description = "output for virtual machines"
  value       = module.web-mod.VM-private_ip
}

# output "bastion_sg" {
#   value       = module.sec-gp.bastion_sg
#   description = "security group id of bastion"
# }

# output "private_sg" {
#   value       = module.sec-gp.private_sg
#   description = "security group id of private vms"
# }
