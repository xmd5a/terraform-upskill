variable "vpc_id" {
  type = string
}

variable "igw" {
  type = object({
    tags = map(string)
  })
}

variable "rt" {
  type = object({
    tags = map(string)
    routes = list(object({
      cidr_block = string
      gateway_id = string
    }))
  })
}