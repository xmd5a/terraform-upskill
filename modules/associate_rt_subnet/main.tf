module "associate" {
  source   = "./associate"
  for_each = { for index, associate in var.associate : index => associate }

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}