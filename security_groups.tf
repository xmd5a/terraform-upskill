module "public_ec2_sg" {
  source = "./modules/security_group"

  name        = var.security_groups.public_ec2.resource_name
  description = var.security_groups.public_ec2.resource_name
  vpc_id      = module.network.vpc_id

  tags = {
    Name = var.security_groups.public_ec2.resource_name
  }
}

module "private_ec2_sg" {
  source = "./modules/security_group"

  name        = var.security_groups.private_ec2.resource_name
  description = var.security_groups.private_ec2.resource_name
  vpc_id      = module.network.vpc_id

  tags = {
    Name = var.security_groups.private_ec2.resource_name
  }
}

module "rds_sg" {
  source = "./modules/security_group"

  name        = var.security_groups.rds.resource_name
  description = var.security_groups.rds.resource_name
  vpc_id      = module.network.vpc_id

  tags = {
    Name = var.security_groups.rds.resource_name
  }
}

module "sg_lb_fe" {
  source = "./modules/security_group"

  name        = var.security_groups.lb_fe.resource_name
  description = var.security_groups.lb_fe.resource_name
  vpc_id      = module.network.vpc_id

  tags = {
    Name = var.security_groups.lb_fe.resource_name
  }
}

module "sg_lb_be" {
  source = "./modules/security_group"

  name        = var.security_groups.lb_be.resource_name
  description = var.security_groups.lb_be.resource_name
  vpc_id      = module.network.vpc_id

  tags = {
    Name = var.security_groups.lb_be.resource_name
  }
}

module "public_ec2_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.public_ec2_sg.sg_id
  rules = [
    {
      type        = "ingress"
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "private_ec2_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.private_ec2_sg.sg_id
  rules = [
    {
      type                     = "ingress"
      description              = "HTTP"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.public_ec2_sg.sg_id
    },
    {
      type                     = "ingress"
      description              = "HTTP"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.sg_lb_be.sg_id
    },
    {
      type        = "egress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type                     = "egress"
      description              = "MYSQL/Aurora"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.rds_sg.sg_id
    }
  ]
}

module "rds_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.rds_sg.sg_id
  rules = [
    {
      type                     = "ingress"
      description              = "MYSQL/Aurora"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.private_ec2_sg.sg_id
    },
    {
      type                     = "egress"
      description              = "MYSQL/Aurora"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.private_ec2_sg.sg_id
    }
  ]
}

module "lb_fe_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.sg_lb_fe.sg_id
  rules = [
    {
      type        = "ingress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "lb_be_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.sg_lb_be.sg_id
  rules = [
    {
      type        = "ingress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      source_security_group_id = module.public_ec2_sg.sg_id
    },
    {
      type        = "egress"
      description = "all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      # source_security_group_id = module.sg_lb_fe.sg_id
    }
  ]
}