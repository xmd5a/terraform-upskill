module "s3" {
  source = "./modules/s3"

  name = var.s3_resource_name
  tags = {
    Name = var.s3_resource_name
  }
}