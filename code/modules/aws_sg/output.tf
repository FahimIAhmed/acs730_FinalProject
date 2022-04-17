output "aws_security_group_elb" {
    value = aws_security_group.elb_sg.id
}

output "aws_security_group_ws" {
    value = aws_security_group.webserver_sg.id
}

