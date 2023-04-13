variable "database" {
  type = object({
    identifier    = string
    resource_name = string
    name          = string
    user          = string
    password      = string
    subnets = list(object({
      name              = string
      cidr_block        = string
      availability_zone = string
      tags              = map(string)
    }))
  })
}

variable "load_balancers" {
  type = object({
    backend = object({
      resource_name = string
      lt = object({
        description = string
      })
    })
    frontend = object({
      resource_name = string
      lt = object({
        description = string
      })
    })
  })
}

variable "network" {
  type = object({
    vpc = object({
      resource_name = string
      cidr_block    = string
    })
    subnets = list(object({
      name              = string
      cidr_block        = string
      availability_zone = string
      tags              = map(string)
    }))
    igw = object({
      resource_name = string
    })
    nat = object({
      resource_name = string
    })
  })
}

variable "security_groups" {
  type = object({
    public_ec2 = object({
      resource_name = string
    })
    private_ec2 = object({
      resource_name = string
    })
    rds = object({
      resource_name = string
    })
    lb_fe = object({
      resource_name = string
    })
    lb_be = object({
      resource_name = string
    })
  })
}

variable "s3_resource_name" {
  type = string
}