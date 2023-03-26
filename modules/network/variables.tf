variable "vpc" {
  type = object({
    cidr_block = string
    tags       = map(string)
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