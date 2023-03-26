output "subnets" {
  value = values(module.subnets)[*].id
}

output "db_hostname" {
  value = aws_db_instance.main.address
}