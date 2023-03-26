module "ec2_instance" {
  source   = "./init_ec2"
  for_each = { for ec2_instance in var.instances : ec2_instance.private_ip => ec2_instance }

  is_public            = each.value.is_public
  iam_instance_profile = each.value.iam_instance_profile
  private_ip           = each.value.private_ip
  ami                  = each.value.ami
  instance_type        = each.value.instance_type
  availability_zone    = each.value.availability_zone
  key_name             = each.value.key_name
  user_data            = each.value.user_data
  tags                 = each.value.tags
  subnet               = each.value.subnet
  security_groups      = each.value.security_groups
}