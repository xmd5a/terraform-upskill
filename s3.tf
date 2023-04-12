module "s3" {
  source = "./modules/s3"

  name = "pszarmach-s3"
  tags = {
    Name = "pszarmach"
  }
}