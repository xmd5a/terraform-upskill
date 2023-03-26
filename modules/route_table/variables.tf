variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "routes" {
  type = list(object({
    cidr_block = string
    gateway_id = string
  }))
}