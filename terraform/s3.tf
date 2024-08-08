module "s3_explore_bucket" {
  source                  = "cloudposse/s3-bucket/aws"
  version                 = "4.2.0"
  name                    = "cams-explore-tf-bucket"
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
  kms_master_key_arn            = aws_kms_key.s3_explore_bucket_key.arn
  bucket_key_enabled            = true

  context = module.this.context
  depends_on = [aws_kms_key.s3_bucket_key ]
}


data "aws_iam_policy_document" "cams_tf_explore_s3_bucket_policy" {
  // Enforce SSL Connection
  statement {
    sid     = "AllowSSLRequestsOnlyExploreBucket"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${module.s3_explore_bucket.bucket_arn}/*",
      module.s3_explore_bucket.bucket_arn
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

resource "aws_s3_bucket_policy" "attach_s3_explore_bucket_policy" {
  bucket = module.s3_explore_bucket.bucket_id
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
  kms_master_key_arn            = aws_kms_key.s3_processing_bucket_key.arn
  bucket_key_enabled            = true

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
data "aws_iam_policy_document" "objects_processing_bucket_policy_document" {
  // Enforce SSL Connection
  statement {
    sid     = "AllowSSLRequestsOnlyProcessingBucket"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "${module.objects_processing_bucket.bucket_arn}/*",
      module.objects_processing_bucket.bucket_arn
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

resource "aws_s3_bucket_policy" "attach_s3_processing_bucket_policy" {
  bucket = module.objects_processing_bucket.bucket_id
  policy = data.aws_iam_policy_document.objects_processing_bucket_policy_document.json
}


resource "aws_s3_bucket_notification" "processing-bucket-event-notifications" {
  bucket = module.objects_processing_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.S3_trigger_lambda_process_objects.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ingestion/"
  }

  depends_on = [ module.objects_processing_bucket, aws_lambda_permission.lambda_process_s3_objects ]
}