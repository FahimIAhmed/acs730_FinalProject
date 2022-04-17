# Provision SSH key pair for Linux VMs
resource "aws_key_pair" "launch_key" {
  key_name   = "launch_key"
  public_key = file(var.path_to_key)
    # tags = merge({
    # Name = "${local.name_prefix}-keypair"
    # },
    # local.default_tags
  # )
}

#Create Launch config
resource "aws_launch_configuration" "webserver-launch-config" {
  name_prefix     = "webserver-launch-config"
  image_id        =  data.aws_ami.ami-amzn2.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.launch_key.key_name
  #  key_name        = var.keyname
  security_groups = ["${aws_security_group.webserver_sg.id}"]

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = 5
    encrypted   = true
  }


  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64("${path.module}/init_webserver.sh")
}


# Create Auto Scaling Group
resource "aws_autoscaling_group" "acs730-ASG-tf" {
  name                 = "acs730-ASG-tf"
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  force_delete         = true
  depends_on           = [aws_lb.ALB-tf]
  target_group_arns    = ["${aws_lb_target_group.TG-tf.arn}"]
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.webserver-launch-config.name
  vpc_zone_identifier  = ["${aws_subnet.prv_sub1.id}", "${aws_subnet.prv_sub2.id}"]

  tag {
    key                 = "Name"
    value               = "acs730-ASG-tf"
    propagate_at_launch = true
  }
}

# Create Target group

resource "aws_lb_target_group" "TG-tf" {
  name       = "acs730-TargetGroup-tf"
  depends_on = [aws_vpc.main]
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

# Create ALB

resource "aws_lb" "ALB-tf" {
  name               = "acs730-ALG-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]

  tags = {
    name    = "acs730-AppLoadBalancer-tf"
    Project = "acs730-assignment"
  }
}

# Create ALB Listener 

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG-tf.arn
  }
}

