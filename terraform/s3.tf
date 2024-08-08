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


### Create an S3 bucket
### use cloudposse/s3-bucket/aws module
### https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/latest
### create a ingestion key
### create a processed key
### create a trigger for a lambda function to process the files in the ingestion key
module "objects_processing_bucket" {
  source                  = "cloudposse/s3-bucket/aws"
  version                 = "4.2.0"
  name                    = "objects-processing-bucket"
  versioning_enabled      = false
  s3_object_ownership     = var.s3_bucket_owner_enforced
  allow_ssl_requests_only = true

  context = module.this.context
}

resource "aws_s3_bucket_notification" "bucket-event-notifications" {
  bucket = module.ods_bucket.bucket_id

  lambda_function {
    lambda_function_arn = module.trigger-preference-data.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/preferences/"
  }

  lambda_function {
    lambda_function_arn = module.trigger_ingest_customer_extended_contacts.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/customer-contacts/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-pre-activation-candidate-psps.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/psps-export/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-ingest-pre-act-cand-lc.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/lc-export/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-tribal-lands.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/tribal-data/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-psps-planned.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/psps-planned/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-customer-informations.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/customerinformations/"
  }

  lambda_function {
    lambda_function_arn = module.trigger-child-contacts.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "ods-landing/child-contacts/"
  }

  depends_on = [
    aws_lambda_permission.trigger-preference-data,
    aws_lambda_permission.trigger-ingest-pre-act-cand-lc,
    aws_lambda_permission.trigger-pre-activation-candidate-psps,
    aws_lambda_permission.trigger_ingest_customer_extended_contacts,
    aws_lambda_permission.trigger-tribal-lands,
    aws_lambda_permission.trigger-psps-planned,
    aws_lambda_permission.trigger-customer-informations,
    aws_lambda_permission.trigger-child-contacts
  ]
}