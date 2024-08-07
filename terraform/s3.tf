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