resource "aws_security_group_rule" "main" {
  count = length(var.rules)

  type                     = var.rules[count.index].type
  from_port                = var.rules[count.index].from_port
  to_port                  = var.rules[count.index].to_port
  protocol                 = var.rules[count.index].protocol
  cidr_blocks              = try(var.rules[count.index].cidr_blocks, [])
  source_security_group_id = try(var.rules[count.index].source_security_group_id, null)
  security_group_id        = var.security_group_id
}
