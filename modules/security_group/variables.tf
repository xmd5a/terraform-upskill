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
    description     = optional(string)
    from_port       = optional(number)
    to_port         = optional(number)
    protocol        = optional(string)
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description     = optional(string)
    from_port       = optional(number)
    to_port         = optional(number)
    protocol        = optional(string)
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}