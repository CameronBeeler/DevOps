data "aws_iam_policy_document" "kms_decrypt" {
  statement {
    sid       = "KMSDecrypt"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
  }
}

resource "aws_iam_policy" "kms_decrypt" {
  name        = "lambda_kms_decrypt"
  description = "Policy to allow decrypting KMS keys for interface repo"
  policy      = data.aws_iam_policy_document.kms_decrypt.json
}