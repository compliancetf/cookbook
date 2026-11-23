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
