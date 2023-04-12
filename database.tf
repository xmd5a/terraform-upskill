module "rds" {
  source = "./modules/rds"

  vpc_id = module.network.vpc_id
  sg_id  = module.pszarmach_rds_sg.sg_id

  subnet_group = {
    name        = "pszarmach-subnet-rds"
    description = "pszarmach-subnet-rds"
  }
  db = {
    identifier = "pszarmach-db"
    name       = "app"
    user       = "admin"
    password   = "FLizVBSeNazaPcgJaMvm"
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