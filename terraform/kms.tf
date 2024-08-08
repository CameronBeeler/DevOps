resource "aws_kms_key" "s3_bucket_key" {
  description             = "KMS key for S3 bucket cams-explore-tf-bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = aws_iam_policy_document.kms_s3_bucket_policy_document.json

}

resource "aws_iam_policy_document" "kms_s3_bucket_policy_document" {
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
        "arn:aws:iam::${var.aws_account_id}:user/*"
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