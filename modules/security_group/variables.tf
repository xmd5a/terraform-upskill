variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ingress_rules" {
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
}

variable "egress_rules" {
  type = list(object({ description = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
}