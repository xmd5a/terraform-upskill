module "backend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  lb_sg = module.pszarmach_sg_lb_be.sg_id

  asg = {
    name    = "pszarmach-be-asg"
    subnets = [module.network.subnets.private_first.id, module.network.subnets.private_second.id]
  }

  tg = {
    name = "pszarmach-tg-be"
  }

  ap = {
    name = "pszarmach-ap-be"
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
    sg                      = [module.pszarmach_private_ec2_sg.sg_id]
    public                  = false
    iam_instance_profile = module.s3.iam_profile_id
  }

  lb_listener = {
    name = "pszarmach-lb-listener-be"
  }

  depends_on = [module.igw.igw_id, module.nat.nat_gw_id, module.rds.db_hostname, module.s3.iam_profile_id]
}

module "frontend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  lb_sg = module.pszarmach_sg_lb_fe.sg_id

  asg = {
    name    = "pszarmach-fe-asg"
    subnets = [module.network.subnets.public_first.id, module.network.subnets.public_second.id]
  }

  tg = {
    name = "pszarmach-tg-fe"
  }

  ap = {
    name = "pszarmach-ap-fe"
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
    sg     = [module.pszarmach_public_ec2_sg.sg_id]
    public = true
  }

  lb_listener = {
    name = "pszarmach-lb-listener-fe"
  }

  depends_on = [module.backend_load_balancer.dns_name]
}