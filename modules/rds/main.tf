module "subnets" {
  source   = "../subnet"
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}

resource "aws_db_subnet_group" "main" {
  name        = var.subnet_group.name
  description = var.subnet_group.description
  subnet_ids  = tolist(values(module.subnets))[*].id
}

resource "aws_db_instance" "main" {
  identifier                = var.db.identifier
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "8.0.28"
  instance_class            = "db.t3.micro"
  db_name                   = var.db.name
  username                  = var.db.user
  password                  = var.db.password
  db_subnet_group_name      = aws_db_subnet_group.main.id
  vpc_security_group_ids    = [var.sg_id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}