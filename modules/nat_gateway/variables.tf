variable "vpc_id" {
  type = string
}

variable "tag_name" {
  type = string
}

variable "subnet_id" {
  type = string
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