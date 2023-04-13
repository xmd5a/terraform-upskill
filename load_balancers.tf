module "backend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  lb_sg = module.sg_lb_be.sg_id

  asg = {
    name    = "${var.load_balancers.backend.resource_name}-asg"
    subnets = [module.network.subnets.private_first.id, module.network.subnets.private_second.id]
  }

  tg = {
    name = "${var.load_balancers.backend.resource_name}-tg"
  }

  ap = {
    name = "${var.load_balancers.backend.resource_name}-ap"
  }

  lb = {
    name     = "${var.load_balancers.backend.resource_name}-lb"
    subnets  = [module.network.subnets.private_first.id, module.network.subnets.private_second.id]
    internal = true
  }

  lt = {
    name          = "${var.load_balancers.backend.resource_name}-ec2-private"
    description   = "${var.load_balancers.backend.lt.description}"
    template_file = "backend_sh.tpl"
    user_data_vars = {
      db_hostname = module.rds.db_hostname
      db_name     = var.database.name
      db_user     = var.database.user
      db_password = var.database.password
      s3_bucket   = var.s3_resource_name
    }
    sg                   = [module.private_ec2_sg.sg_id]
    public               = false
    iam_instance_profile = module.s3.iam_profile_id
  }

  lb_listener = {
    name = "${var.load_balancers.backend.resource_name}-lb-listener"
  }

  depends_on = [module.igw.igw_id, module.nat.nat_gw_id, module.rds.db_hostname, module.s3.iam_profile_id]
}

module "frontend_load_balancer" {
  source = "./modules/load-balancer"

  vpc_id = module.network.vpc_id

  lb_sg = module.sg_lb_fe.sg_id

  asg = {
    name    = "${var.load_balancers.frontend.resource_name}-asg"
    subnets = [module.network.subnets.public_first.id, module.network.subnets.public_second.id]
  }

  tg = {
    name = "${var.load_balancers.frontend.resource_name}-tg"
  }

  ap = {
    name = "${var.load_balancers.frontend.resource_name}-ap"
  }

  lb = {
    name     = "${var.load_balancers.frontend.resource_name}-lb"
    subnets  = [module.network.subnets.public_first.id, module.network.subnets.public_second.id]
    internal = false
  }

  lt = {
    name          = "${var.load_balancers.frontend.resource_name}-ec2-public"
    description   = "${var.load_balancers.frontend.lt.description}"
    template_file = "frontend_sh.tpl"
    user_data_vars = {
      api_url = "http://${module.backend_load_balancer.dns_name}"
    }
    sg     = [module.public_ec2_sg.sg_id]
    public = true
  }

  lb_listener = {
    name = "${var.load_balancers.frontend.resource_name}-lb-listener"
  }

  depends_on = [module.backend_load_balancer.dns_name]
}