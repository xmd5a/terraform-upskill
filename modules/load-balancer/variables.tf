variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "launch_template_sg" {
  type = list(string)
}
