output "ec2_ip" {
  value = toset(aws_eip.webserver_eip)[*].public_ip
}