variable "vpc_id" {
  type = string
}

variable "db" {
  type = object({
    identifier     = string
    name           = string
    user           = string
    password       = string
    security_group = string
  })
}

variable "subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
}

variable "subnet_group" {
  type = object({
    name        = string
    description = string
  })
}