output "igw" {
  value = aws_internet_gateway.gate
}

output "igw_id" {
  value = aws_internet_gateway.gate.id
}

output "rt" {
  value = module.route_table_public_internet
}

output "rt_id" {
  value = module.route_table_public_internet.rt_id
}