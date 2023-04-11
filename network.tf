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