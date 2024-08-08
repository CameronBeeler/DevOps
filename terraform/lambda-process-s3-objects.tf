
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../src/lambda-process-s3-objects/lambda-process-s3-objects.py"
  output_path = "${path.module}/lambda-process-s3-objects.zip"
#   source_file = "../src/lambda-process-s3-objects/*"
#   source_dir  = "../src/lambda-process-s3-objects"
}

module "S3_trigger_lambda_process_objects" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.5.3"
  name                               = "lambda_process_s3_objects"
  description                        = "Lambda function to process objects in the S3 bucket"
  filename                           = "${path.module}/src/lambda/lambda_process_s3_objects.zip"
  function_name                      = "lambda_process_s3_objects"
  handler                            = "lambda_process_s3_objects.lambda_handler"
  runtime                            = "python3.10"
  tracing_config_mode                = "Active"
  timeout                            = 30
  cloudwatch_lambda_insights_enabled = true
  cloudwatch_logs_retention_in_days  = 30

  custom_iam_policy_arns = [
    "arn:aws:iam::${local.aws_account_id}:policy/lambda_kms_decrypt",
    "arn:aws:iam::${local.aws_account_id}:policy/lambda_process_objects_execution_policy"
  ]

  layers = []

  lambda_environment = {
    variables = {
      "testinput"  = "hello Cameron"
    }
  }

  context = module.this.context

  depends_on = [ 
    data.archive_file.lambda_zip,
    aws_iam_policy.lambda_execution_policy
  ]

}

data "aws_iam_policy_document" "lambda_execution_policy_document" {
    statement {
    sid    = "LambdaExecutionPolicyS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:PutObjectTagging",
      "s3:GetObjectTagging",
      "s3:PutObjectAcl",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion",
      "s3:DeleteObjectVersion",
      "s3:ListAllMyBuckets",
      "s3:CopyObject"
    ]
    resources = [
      module.objects_processing_bucket.bucket_arn,
      "${module.objects_processing_bucket.bucket_arn}/*"
    ]
  }
  statement {
    sid    = "LambdaExecutionPolicyCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/*"
    ]
  }

    statement {
    sid    = "LambdaExecutionPolicySQSAccess"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags"
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:${local.aws_account_id}:*"
    ]
  }

  statement {
    sid    = "LambdaExecutionPolicySNSAccess"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
      "sns:Receive",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = [
      "arn:aws:sns:${var.aws_region}:${local.aws_account_id}:*"
    ]
  }

  statement {
    sid    = "LambdaExecutionPolicyDynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["*"]
  }
 
}

# make lambda name
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda_process_objects_execution_policy"
  description = "provide broad access to lambda in anticipation of is future needs"
  policy      = data.aws_iam_policy_document.lambda_execution_policy_document.json

  depends_on = [ module.objects_processing_bucket ]
}

resource "aws_lambda_permission" "lambda_process_s3_objects" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.S3_trigger_lambda_process_objects.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.objects_processing_bucket.bucket_arn

  depends_on = [ module.S3_trigger_lambda_process_objects, module.objects_processing_bucket ]
}
