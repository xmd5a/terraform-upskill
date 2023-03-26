variable "is_public" {
  type = bool
}

variable "iam_instance_profile" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "key_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "user_data" {
  type = string
}

variable "subnet" {
  type = string
}

variable "security_groups" {
  type = list(string)
} 