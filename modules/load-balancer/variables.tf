variable "vpc_id" {
  type = string
}

variable "asg" {
  type = object({
    name    = string
    subnets = list(string)
  })
}

variable "tg" {
  type = object({
    name = string
  })
}

variable "lb" {
  type = object({
    name     = string
    subnets  = list(string)
    internal = bool
  })
}

variable "lt" {
  type = object({
    name                 = string
    description          = string
    template_file        = string
    user_data_vars       = map(string)
    sg                   = list(string)
    public               = bool
    iam_instance_profile = optional(string)
  })
}

variable "lb_listener" {
  type = object({
    name = string
  })
}

variable "sg" {
  type = object({
    name        = string
    description = string
    ingress_rules = list(object({
      description     = string
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
    }))
    egress_rules = list(object({
      description     = string
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
    }))
  })
}
