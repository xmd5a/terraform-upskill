variable "security_group_id" {
  type = string
}

variable "rules" {
  type = list(object({
    type                     = string
    description              = string
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
  default = []
}
