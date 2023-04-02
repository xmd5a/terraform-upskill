module "network" {
  source = "./modules/network"

  vpc = {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "pszarmach-vpc"
    }
  }
  subnets = [{
    name              = "public_first"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "pszarmach-public-subnet-east-1a"
    }
    }, {
    name              = "public_second"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "pszarmach-public-subnet-east-1b"
    }
    }, {
    name              = "private_first"
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "pszarmach-private-subnet-east-1a"
    }
    }, {
    name              = "private_second"
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "pszarmach-private-subnet-east-1b"
    }
  }]
}

module "igw" {
  source = "./modules/internet_gateway"

  vpc_id = module.network.vpc_id
  igw = {
    tags = {
      Name = "pszarmach-igw"
    }
  }
  rt = {
    routes = [{
      cidr_block = "0.0.0.0/0"
      gateway_id = module.igw.igw_id
    }]
    tags = {
      Name = "pszarmach-rt-access-2-public-internet"
    }
  }
}

module "nat" {
  source = "./modules/nat_gateway"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnets.public_first.id
  tag_name  = "pszarmach"
  rt = {
    routes = [{
      cidr_block = "0.0.0.0/0"
      gateway_id = module.nat.nat_gw_id
    }]
    tags = {
      Name = "pszarmach-route-table-private-subnet"
    }
  }

  depends_on = [module.igw.igw_id]
}

module "sg_allow_web_ssh" {
  source = "./modules/security_group"

  name        = "allow_web_ssh"
  description = "Allow web:80 and ssh:22"
  vpc_id      = module.network.vpc_id

  ingress_rules = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
    Name = "pszarmach-allow-web-sg"
  }
}

module "allow_web_ssh_from_public_subnet" {
  source = "./modules/security_group"

  name        = "allow_web_ssh_from_public_subnet"
  description = "Allow web:80 and ssh:22"
  vpc_id      = module.network.vpc_id

  ingress_rules = [{
    description     = "inbound"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [module.sg_allow_web_ssh.sg_id]
  }]

  egress_rules = [{
    description = "outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  tags = {
    Name = "pszarmach-allow-web-sg-from-public-subnet"
  }
}

module "associate_rt_subnet" {
  source = "./modules/associate_rt_subnet"

  associate = [{
    subnet_id      = module.network.subnets.public_first.id
    route_table_id = module.igw.rt_id
    }, {
    subnet_id      = module.network.subnets.public_second.id
    route_table_id = module.igw.rt_id
    }, {
    subnet_id      = module.network.subnets.private_first.id
    route_table_id = module.nat.rt_id
    }, {
    subnet_id      = module.network.subnets.private_second.id
    route_table_id = module.nat.rt_id
  }]
}

module "rds" {
  source = "./modules/rds"

  vpc_id = module.network.vpc_id
  subnet_group = {
    name        = "pszarmach-subnet-rds"
    description = "pszarmach-subnet-rds"
  }
  db = {
    identifier     = "pszarmach-db"
    name           = "app"
    user           = "admin"
    password       = "FLizVBSeNazaPcgJaMvm"
    security_group = module.allow_web_ssh_from_public_subnet.sg_id
  }
  subnets = [{
    name              = "rds_1st"
    cidr_block        = "10.0.5.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name = "pszarmach-rds-subnet-us-east-1a"
    }
    }, {
    name              = "rds_2nd"
    cidr_block        = "10.0.6.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "pszarmach-rds-subnet-us-east-1b"
    }
  }]
}

module "s3" {
  source = "./modules/s3"

  name = "pszarmach-s3"
  tags = {
    Name = "pszarmach"
  }
}

module "backend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  asg = {
    name    = "pszarmach-be-asg"
    subnets = [module.network.subnets.private_first.id, module.network.subnets.private_second.id]
  }

  tg = {
    name = "pszarmach-tg-be"
  }

  lb = {
    name     = "pszarmach-lb-be"
    subnets  = [module.network.subnets.private_first.id, module.network.subnets.private_second.id]
    internal = true
  }

  lt = {
    name          = "pszarmach-ec2-private-be"
    description   = "private BE launch template"
    template_file = "backend_sh.tpl"
    user_data_vars = {
      db_hostname = module.rds.db_hostname
    }
    sg                      = [module.allow_web_ssh_from_public_subnet.sg_id]
    public                  = false
    iamiam_instance_profile = module.s3.iam_profile_id
  }

  lb_listener = {
    name = "pszarmach-lb-listener-be"
  }

  sg = {
    name        = "pszarmach-sg-lb-be"
    description = "security group for backend load balancer"
    ingress_rules = [
      {
        description     = "HTTP"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [module.sg_allow_web_ssh.sg_id]
      },
    ],
    egress_rules = [
      {
        description     = "HTTP"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [module.allow_web_ssh_from_public_subnet.sg_id]
      }
    ]
  }

  depends_on = [module.igw.igw_id, module.nat.nat_gw_id, module.rds.db_hostname, module.s3.iam_profile_id]
}

module "frontend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  asg = {
    name    = "pszarmach-fe-asg"
    subnets = [module.network.subnets.public_first.id, module.network.subnets.public_second.id]
  }

  tg = {
    name = "pszarmach-tg-fe"
  }

  lb = {
    name     = "pszarmach-lb-fe"
    subnets  = [module.network.subnets.public_first.id, module.network.subnets.public_second.id]
    internal = false
  }

  lt = {
    name          = "pszarmach-ec2-public-fe"
    description   = "public FE launch template"
    template_file = "frontend_sh.tpl"
    user_data_vars = {
      api_url = "http://${module.backend_load_balancer.dns_name}"
    }
    sg     = [module.sg_allow_web_ssh.sg_id]
    public = true
  }

  lb_listener = {
    name = "pszarmach-lb-listener-fe"
  }

  sg = {
    name        = "pszarmach-sg-lb-fe"
    description = "security group for frontend load balancer"
    ingress_rules = [
      {
        description = "all"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
    ],
    egress_rules = [
      {
        description = "all"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  depends_on = [module.backend_load_balancer.dns_name]
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "igw_id" {
  value = module.igw.igw_id
}

output "public_rt_id" {
  value = module.igw.rt_id
}

output "private_rt_id" {
  value = module.nat.rt_id
}

output "subnets" {
  value = module.network.subnets
}

output "rds_subnets" {
  value = module.rds.subnets
}

output "nat_gw_id" {
  value = module.nat.nat_gw_id
}

output "sg_allow_web_ssh_id" {
  value = module.sg_allow_web_ssh.sg_id
}

# output "ec2_public_ip" {
#   value = module.ec2_instance_public.ec2_ip
# }

output "rds_hostname" {
  value = module.rds.db_hostname
}

output "s3_bucket" {
  value = module.s3.s3_bucket
}

output "iam_profile_id" {
  value = module.s3.iam_profile_id
}

output "dns_frontend_name" {
  value = module.frontend_load_balancer.dns_name
}

output "dns_backend_name" {
  value = module.backend_load_balancer.dns_name
}