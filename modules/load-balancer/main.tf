module "pszarmach_sg_lb_fe" {
  source = "../security_group"

  name        = "pszarmach-sg-lb-fe"
  description = "security group for frontend load balancer"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  egress_rules = [
    {
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "pszarmach-sg-lb-fe"
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "pszarmach-tg-fe"
  vpc_id      = var.vpc_id
  port        = 80     # not sure about this value
  protocol    = "HTTP" # not sure about this value
  target_type = "instance"

  tags = {
    Name = "pszarmach-tg-fe"
  }
}

# VPC?
resource "aws_lb" "frontend" {
  name               = "pszarmach-lb-fe"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.pszarmach_sg_lb_fe.sg_id]
  subnets            = var.subnets

  tags = {
    Name = "pszarmach-lb-fe"
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  tags = {
    Name = "pszarmach-lb-listener-fe"
  }
}

# unknown config?
resource "aws_launch_template" "frontend" {
  # name        = "pszarmach-ec2-public-fe-template"
  name_prefix   = "pszarmach-fe-"
  description   = "public FE launch template"
  image_id      = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"

  key_name               = "pszarmach"
  user_data = base64encode(templatefile("${path.module}/../../frontend_sh.tpl", {
    api_url = "http://10.0.3.10"
  }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.launch_template_sg
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "pszarmach-ec2-public-fe"
    }
  }
}

resource "aws_autoscaling_group" "frontend" {
  name = "pszarmach-fe-asg"
  desired_capacity    = 3
  max_size            = 12
  min_size            = 3
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }
}

resource "aws_autoscaling_attachment" "frontend" {
  autoscaling_group_name = aws_autoscaling_group.frontend.id
  alb_target_group_arn   = aws_lb_target_group.frontend.arn
}