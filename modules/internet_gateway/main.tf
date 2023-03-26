resource "aws_internet_gateway" "gate" {
  vpc_id = var.vpc_id

  tags = var.igw.tags
}

module "route_table_public_internet" {
  source = "../route_table"

  vpc_id = var.vpc_id
  tags   = var.rt.tags
  routes = var.rt.routes
}