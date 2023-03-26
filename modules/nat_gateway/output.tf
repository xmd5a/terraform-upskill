output "nat_gw" {
  value = aws_nat_gateway.gw
}

output "nat_gw_id" {
  value = aws_nat_gateway.gw.id
}

output "rt_id" {
  value = module.route_table_private.rt_id
}