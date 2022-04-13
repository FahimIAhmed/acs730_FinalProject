output "public_ip" {
  value = aws_instance.my_amazon.public_ip
}

output "web_eip" {
  value = aws_eip.static_eip.public_ip
}