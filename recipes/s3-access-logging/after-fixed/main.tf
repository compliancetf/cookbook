# after/ plus the inputs the soc2 plan errors ask for: one block per control.
module "s3_bucket" {
  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket = var.bucket_name

  versioning = {
    enabled = true
    # s3_bucket_mfa_delete_enabled. AWS applies this only with the root
    # user's credentials and MFA device.
    mfa_delete = true
  }

  # s3_bucket_logging_enabled
  logging = {
    target_bucket = var.log_bucket_name
    target_prefix = "s3-access-logs/"
  }

  # s3_bucket_default_encryption_enabled_kms
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_arn
      }
      bucket_key_enabled = true
    }
  }

  # s3_bucket_versioning_and_lifecycle_policy_enabled
  lifecycle_rule = [
    {
      id      = "expire-noncurrent-versions"
      enabled = true

      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  ]

  # s3_bucket_cross_region_replication_enabled
  replication_configuration = {
    role = var.replication_role_arn

    rules = [
      {
        id     = "replicate-all"
        status = "Enabled"

        delete_marker_replication = true

        destination = {
          bucket        = var.replica_bucket_arn
          storage_class = "STANDARD"
        }
      }
    ]
  }
}
