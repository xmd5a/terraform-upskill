module "pszarmach_public_ec2_sg" {
  source = "./modules/security_group"

  name        = "pszarmach_public_ec2_sg"
  description = "pszarmach_public_ec2_sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "pszarmach_public_ec2_sg"
  }
}

module "pszarmach_private_ec2_sg" {
  source = "./modules/security_group"

  name        = "pszarmach_private_ec2_sg"
  description = "pszarmach_private_ec2_sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "pszarmach_private_ec2_sg"
  }
}

module "pszarmach_rds_sg" {
  source = "./modules/security_group"

  name        = "pszarmach_rds_sg"
  description = "pszarmach_rds_sg"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "pszarmach_rds_sg"
  }
}

module "pszarmach_sg_lb_fe" {
  source = "./modules/security_group"

  name        = "pszarmach_sg_lb_fe"
  description = "pszarmach_sg_lb_fe"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "pszarmach_sg_lb_fe"
  }
}

module "pszarmach_sg_lb_be" {
  source = "./modules/security_group"

  name        = "pszarmach_sg_lb_be"
  description = "pszarmach_sg_lb_be"
  vpc_id      = module.network.vpc_id

  tags = {
    Name = "pszarmach_sg_lb_be"
  }
}

module "pszarmach_public_ec2_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.pszarmach_public_ec2_sg.sg_id
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

module "pszarmach_private_ec2_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.pszarmach_private_ec2_sg.sg_id
  rules = [
    {
      type                     = "ingress"
      description              = "HTTP"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.pszarmach_public_ec2_sg.sg_id
    },
    {
      type                     = "ingress"
      description              = "HTTP"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      source_security_group_id = module.pszarmach_sg_lb_be.sg_id
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
      source_security_group_id = module.pszarmach_rds_sg.sg_id
    }
  ]
}

module "pszarmach_rds_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.pszarmach_rds_sg.sg_id
  rules = [
    {
      type                     = "ingress"
      description              = "MYSQL/Aurora"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.pszarmach_private_ec2_sg.sg_id
    },
    {
      type                     = "egress"
      description              = "MYSQL/Aurora"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.pszarmach_private_ec2_sg.sg_id
    }
  ]
}

module "pszarmach_lb_fe_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.pszarmach_sg_lb_fe.sg_id
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

module "pszarmach_lb_be_sg_rules" {
  source = "./modules/security_group_rule"

  security_group_id = module.pszarmach_sg_lb_be.sg_id
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