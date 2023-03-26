resource "aws_network_interface" "webserver" {
  subnet_id       = var.subnet
  private_ips     = [var.private_ip]
  security_groups = var.security_groups
}

resource "aws_instance" "webserver" {
  ami                  = var.ami
  instance_type        = var.instance_type
  availability_zone    = var.availability_zone
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : null

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.webserver.id
  }

  user_data = var.user_data

  tags = var.tags
}

resource "aws_eip" "webserver_eip" {
  count = var.is_public ? 1 : 0

  vpc                       = true
  instance                  = aws_instance.webserver.id
  associate_with_private_ip = var.private_ip

  tags = {
    Name = "pszarmach-webserver-eip"
  }
}