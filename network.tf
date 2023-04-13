module "network" {
  source = "./modules/network"

  vpc = {
    cidr_block = var.network.vpc.cidr_block
    tags = {
      Name = var.network.vpc.resource_name
    }
  }
  subnets = var.network.subnets
}

module "igw" {
  source = "./modules/internet_gateway"

  vpc_id = module.network.vpc_id
  igw = {
    tags = {
      Name = var.network.igw.resource_name
    }
  }
  rt = {
    routes = [{
      cidr_block = "0.0.0.0/0"
      gateway_id = module.igw.igw_id
    }]
    tags = {
      Name = "${var.network.igw.resource_name}-access-2-public-internet"
    }
  }
}

module "nat" {
  source = "./modules/nat_gateway"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnets.public_first.id
  tag_name  = var.network.nat.resource_name

  rt = {
    routes = [{
      cidr_block = "0.0.0.0/0"
      gateway_id = module.nat.nat_gw_id
    }]
    tags = {
      Name = "${var.network.nat.resource_name}-route-table-private-subnet"
    }
  }

  depends_on = [module.igw.igw_id]
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