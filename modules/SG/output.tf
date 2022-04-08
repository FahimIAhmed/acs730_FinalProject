
# Step 10 - Add output variables
output "web_sg" {
  value = aws_security_group.web_sg.id
}

