# The same bucket, with prevent_destroy added by the registry at download time.
# The rule rides on the source line, where code review sees it. Needs a token in
# ~/.netrc (see docs/auth-setup.md) because the URL form carries query parameters.
module "s3_bucket" {
  source = "https://registry.compliance.tf/terraform-aws-modules/s3-bucket/aws?version=5.15.4&rules=lifecycle_prevent_destroy_data"

  bucket = var.bucket_name
}
