# A typical bucket from an existing estate: versioned, but with
# no access logging. Scanners flag it; the fix most teams reach for is a fork.
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket = var.bucket_name

  versioning = {
    enabled = true
  }
}
