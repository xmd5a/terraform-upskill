resource "aws_vpc" "main" {
  cidr_block = var.vpc.cidr_block

  tags = var.vpc.tags
}

module "subnet" {
  source   = "../subnet"
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}