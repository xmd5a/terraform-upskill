module "rds" {
  source = "./modules/rds"

  vpc_id = module.network.vpc_id
  sg_id  = module.rds_sg.sg_id

  subnet_group = {
    name        = var.database.resource_name
    description = var.database.resource_name
  }
  db = {
    identifier = var.database.identifier
    name       = var.database.name
    user       = var.database.user
    password   = var.database.password
  }
  subnets = var.database.subnets
}