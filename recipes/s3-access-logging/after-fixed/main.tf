# after/ plus the one block the soc2 plan-time error asks for.
module "s3_bucket" {
  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
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
