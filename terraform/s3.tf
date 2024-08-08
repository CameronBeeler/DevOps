resource "aws_s3_bucket" "cams_s3_bucket" {
  bucket = "cams-explore-tf-bucket"

}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_kms_encryption" {
  bucket = aws_s3_bucket.cams_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
  depends_on = [aws_kms_key.s3_bucket_key, aws_s3_bucket.cams_s3_bucket]
}

# module "camerons_tf_explore_bucket" {
#   source              = "cloudposse/s3-bucket/aws"
#   version             = "4.2.0"
#   name                = "cams-cloudpossse-explore-tf-bucket"
#   versioning_enabled  = false
#   s3_object_ownership = "BucketOwnerEnforced"

#   source_policy_documents = [
#     # Allow replication from device state input bucket
#     data.aws_iam_policy_document.cams_tf_explore_s3_bucket_policy.json
#   ]

#   context = module.this.context
# }

data "aws_iam_policy_document" "cams_tf_explore_s3_bucket_policy" {
  // Enforce SSL Connection
  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.cams_s3_bucket.arn}/*",
      aws_s3_bucket.cams_s3_bucket.arn
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

}

resource "aws_s3_bucket_policy" "attach_s3_bucket_policy" {
  bucket = aws_s3_bucket.cams_s3_bucket.id
  policy = data.aws_iam_policy_document.cams_tf_explore_s3_bucket_policy.json
}


### https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/latest

module "objects_processing_bucket" {
  source                  = "cloudposse/s3-bucket/aws"
  version                 = "4.2.0"
  name                    = "objects-processing-bucket"
  lifecycle_configuration_rules = var.s3_lifecycle_configuration_rules
  versioning_enabled            = var.s3_versioning_enabled
  block_public_acls             = var.s3_block_public_acls
  block_public_policy           = var.s3_block_public_policy
  ignore_public_acls            = var.s3_ignore_public_acls
  restrict_public_buckets       = var.s3_restrict_public_buckets
  s3_object_ownership           = var.s3_bucket_owner_enforced
  sse_algorithm                 = var.s3_sse_algorithm
  allow_ssl_requests_only       = true
  force_destroy                 = true  # Ensure all objects are deleted before bucket is destroyed


  context = module.this.context
}

resource "aws_s3_object" "creating_ingestion_key" {
  bucket = module.objects_processing_bucket.bucket_id
  key    = "ingestion/"
  acl    = "private"

  depends_on = [ module.objects_processing_bucket ]
}

resource "aws_s3_object" "creating_processed_key" {
  bucket = module.objects_processing_bucket.bucket_id
  key    = "processed/"
  acl    = "private"

  depends_on = [ module.objects_processing_bucket ]
}


resource "aws_s3_bucket_notification" "bucket-event-notifications" {
  bucket = module.objects_processing_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.S3_trigger_lambda_process_objects.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ingestion/"
  }

  depends_on = [ module.objects_processing_bucket, aws_lambda_permission.lambda_process_s3_objects ]
}