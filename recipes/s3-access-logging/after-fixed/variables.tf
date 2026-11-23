variable "bucket_name" {
  description = "Globally unique bucket name. Replace before running plan."
  type        = string
  default     = "compliance-tf-demo-change-me"
}

variable "log_bucket_name" {
  description = "Existing bucket that receives access logs. Replace before running plan."
  type        = string
  default     = "compliance-tf-demo-logs-change-me"
}

variable "replication_role_arn" {
  description = "IAM role S3 assumes to replicate objects. Replace before running plan."
  type        = string
  default     = "arn:aws:iam::111122223333:role/s3-replication-change-me"
}

variable "replica_bucket_arn" {
  description = "Versioned bucket in another region that receives the replicas. Replace before running plan."
  type        = string
  default     = "arn:aws:s3:::compliance-tf-demo-replica-change-me"
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the bucket. Replace before running plan."
  type        = string
  default     = "arn:aws:kms:eu-west-1:111122223333:key/00000000-0000-0000-0000-000000000000"
}
