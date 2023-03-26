resource "aws_eip" "nat_gw_eip" {
  vpc = true

  tags = {
    Name = "${var.tag_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "${var.tag_name}-nat-gw"
  }
}

module "route_table_private" {
  source = "../route_table"

  vpc_id = var.vpc_id
  tags   = var.rt.tags
  routes = var.rt.routes
}