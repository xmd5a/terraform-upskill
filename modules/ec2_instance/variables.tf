variable "instances" {
  type = list(object({
    is_public            = bool
    iam_instance_profile = optional(string)
    private_ip           = string
    ami                  = string
    instance_type        = string
    availability_zone    = string
    key_name             = string
    user_data            = string
    tags                 = map(string)
    subnet               = string
    security_groups      = list(string)
  }))
}