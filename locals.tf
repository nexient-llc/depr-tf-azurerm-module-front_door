locals {
  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.custom_tags)
}