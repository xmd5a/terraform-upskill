variable "associate" {
  type = list(object({
    subnet_id      = string
    route_table_id = string
  }))
}