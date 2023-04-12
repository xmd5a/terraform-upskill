resource "aws_lb_target_group" "main" {
  name        = var.tg.name
  vpc_id      = var.vpc_id
  port        = 80     # not sure about this value
  protocol    = "HTTP" # not sure about this value
  target_type = "instance"

  tags = {
    Name = var.tg.name
  }
}

resource "aws_autoscaling_policy" "main" {
  name                   = var.ap.name
  # scaling_adjustment     = 2
  # cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"
  # policy_type            = "SimpleScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
    }

    target_value = 10.0
  }
}

resource "aws_lb" "main" {
  name               = var.lb.name
  internal           = var.lb.internal
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.lb.subnets

  tags = {
    Name = var.lb.name
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name = var.lb_listener.name
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "${var.lt.name}-"
  description   = var.lt.description
  image_id      = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  key_name  = "pszarmach"
  user_data = base64encode(templatefile("${path.module}/../../${var.lt.template_file}", var.lt.user_data_vars))

  network_interfaces {
    associate_public_ip_address = var.lt.public
    security_groups             = var.lt.sg
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.lt.name
    }
  }

  iam_instance_profile {
    name = try(var.lt.iam_instance_profile, null)
  }
}

resource "aws_autoscaling_group" "main" {
  name                = var.asg.name
  desired_capacity    = 3
  max_size            = 12
  min_size            = 3
  vpc_zone_identifier = var.asg.subnets

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }
}

resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.id
  alb_target_group_arn   = aws_lb_target_group.main.arn
}