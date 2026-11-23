# Same module, same inputs as the other two framework directories.
# Only the host in the source line differs.
module "s3_bucket" {
  source  = "pcidssv321.compliance.tf/terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket = var.bucket_name

  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = var.log_bucket_name
    target_prefix = "s3-access-logs/"
  }
}
