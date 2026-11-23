# Attempt 1: add prevent_destroy to a module you consume.
# Terraform reserves the lifecycle block name inside module blocks.
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket = "example"

  lifecycle {
    prevent_destroy = true
  }
}
