output "vpc_id" {
  value = module.network.vpc_id
}

output "igw_id" {
  value = module.igw.igw_id
}

output "public_rt_id" {
  value = module.igw.rt_id
}

output "private_rt_id" {
  value = module.nat.rt_id
}

output "subnets" {
  value = module.network.subnets
}

output "rds_subnets" {
  value = module.rds.subnets
}

output "nat_gw_id" {
  value = module.nat.nat_gw_id
}

output "rds_hostname" {
  value = module.rds.db_hostname
}

output "s3_bucket" {
  value = module.s3.s3_bucket
}

output "iam_profile_id" {
  value = module.s3.iam_profile_id
}

output "dns_frontend_name" {
  value = module.frontend_load_balancer.dns_name
}

output "dns_backend_name" {
  value = module.backend_load_balancer.dns_name
}