module "kms_key_for_s3_explore_bucket_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  name    = "kms-key-s3-explore-bucket"
  context = module.this.context
}

resource "aws_kms_key" "s3_explore_bucket_key" {
  description             = "KMS key for S3 bucket cams-explore-tf-bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_s3_explore_bucket_policy_document.json

  tags = merge(
    module.this.tags,
    {
      Name = module.kms_key_for_s3_explore_bucket_label.id
    }
  )
}

resource "aws_kms_alias" "alias_s3_explore_bucket" {
  name          = "alias/s3-explore"
  target_key_id = aws_kms_key.s3_explore_bucket_key.id
}

data "aws_iam_policy_document" "kms_s3_explore_bucket_policy_document" {
  statement {
    sid    = "AllowS3BucketKeyUsage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "sns.amazonaws.com",
        "cloudwatch.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # New statement for KMS key maintenance by IAM users in the account
  statement {
    sid    = "ManageS3BucketKMSKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_account_id}:root"
      ]
    }
    actions = [
      "kms:CancelKeyDeletion", 
      "kms:Create*", 
      "kms:Delete*", 
      "kms:Describe*", 
      "kms:Disable*", 
      "kms:Enable*", 
      "kms:GenerateDataKey", 
      "kms:Get*", 
      "kms:List*", 
      "kms:Put*", 
      "kms:Revoke*", 
      "kms:ScheduleKeyDeletion", 
      "kms:TagResource", 
      "kms:Update*", 
      "kms:UntagResource"
    ]
    resources = ["*"]
  }
}

###################################################
module "kms_key_for_s3_processing_bucket_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  name    = "kms-key-s3-processing-bucket"
  context = module.this.context
}

resource "aws_kms_key" "s3_processing_bucket_key" {
  description             = "KMS key for S3 bucket objects-processing-bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_s3_processing_bucket_policy_document.json

  tags = merge(
    module.this.tags,
    {
      Name = module.kms_key_for_s3_processing_bucket_label.id
    }
  )

}

resource "aws_kms_alias" "alias_s3_processing_objects" {
  name          = "alias/s3-processing"
  target_key_id = aws_kms_key.s3_processing_bucket_key.id
}

data "aws_iam_policy_document" "kms_s3_processing_bucket_policy_document" {
  statement {
    sid    = "AllowS3BucketKeyUsage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "sns.amazonaws.com",
        "cloudwatch.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # New statement for KMS key maintenance by IAM users in the account
  statement {
    sid    = "ManageS3BucketKMSKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_account_id}:root"
      ]
    }
    actions = [
      "kms:CancelKeyDeletion", 
      "kms:Create*", 
      "kms:Delete*", 
      "kms:Describe*", 
      "kms:Disable*", 
      "kms:Enable*", 
      "kms:GenerateDataKey", 
      "kms:Get*", 
      "kms:List*", 
      "kms:Put*", 
      "kms:Revoke*", 
      "kms:ScheduleKeyDeletion", 
      "kms:TagResource", 
      "kms:Update*", 
      "kms:UntagResource"
    ]
    resources = ["*"]
  }
}

module "kms_key_for_encrypting_lambda_env_vars_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0

  name    = "kms-key-lambda-env-vars"
  context = module.this.context
}

resource "aws_kms_key" "lambda_env_var_key" {
  description             = "KMS key for encrypting lambda environment variables"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_lambda_encrypted_env_vars_document.json

  tags = merge(
    module.this.tags,
    {
      Name = module.kms_key_for_encrypting_lambda_env_vars_label.id
    }
  )

}

resource "aws_kms_alias" "alias_lambda_env_var_key" {
  name          = "alias/lambda-envs"
  target_key_id = aws_kms_key.lambda_env_var_key.id
}

data "aws_iam_policy_document" "kms_lambda_encrypted_env_vars_document" {
  statement {
    sid    = "AllowLambdaAccessToEncryptedEnvVars"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  # New statement for KMS key maintenance by IAM users in the account
  statement {
    sid    = "ManageLambdaKMSKey"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${local.aws_account_id}:root"
      ]
    }
    actions = [
      "kms:CancelKeyDeletion", 
      "kms:Create*", 
      "kms:Delete*", 
      "kms:Describe*", 
      "kms:Disable*", 
      "kms:Enable*", 
      "kms:GenerateDataKey", 
      "kms:Get*", 
      "kms:List*", 
      "kms:Put*", 
      "kms:Revoke*", 
      "kms:ScheduleKeyDeletion", 
      "kms:TagResource", 
      "kms:Update*", 
      "kms:UntagResource"
    ]
    resources = ["*"]
  }
}