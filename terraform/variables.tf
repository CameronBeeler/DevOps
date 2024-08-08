variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"

}

variable "s3_lifecycle_configuration_rules" {
  description = "Lifecycle rules for managing S3 bucket objects"
  type        = list(any)
  default     = []
}

variable "s3_versioning_enabled" {
  description = "Enable versioning on bucket"
  type        = bool
  default     = false
}

variable "s3_block_public_acls" {
  description = "Disallow attaching new public ACLs to bucket"
  type        = bool
  default     = true
}
variable "s3_block_public_policy" {
  description = "Disallow attaching new public policies to bucket"
  type        = bool
  default     = true
}

variable "s3_ignore_public_acls" {
  description = "Ignore public ACLs attached to bucket"
  type        = bool
  default     = true
}
variable "s3_restrict_public_buckets" {
  description = "Prevent making the bucket public"
  type        = bool
  default     = true
}
variable "s3_sse_algorithm" {
  description = "The server-side encryption algorithm to use on the bucket"
  type        = string
  default     = "aws:kms"
}
variable "s3_bucket_owner_enforced" {
  description = "The sdge requirement is to enforce bucket ownership"
  type        = string
  default     = "BucketOwnerEnforced"
}