data "aws_iam_policy_document" "python_lambda_assume_role" {
  statement {
    sid     = "AllowLambdaAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        local.account_id
      ]
    }
  }
}


# KMS
data "aws_iam_policy_document" "kms_read_access" {
  count = local.use_kms_key ? 1 : 0
  statement {
    sid = "AllowKMSReadAccess"
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt",
    ]
    resources = [local.kms_key_id]
  }
}

resource "aws_iam_policy" "kms_read_access" {
  count       = local.use_kms_key != null ? 1 : 0
  name        = "connect-webhook-kms-read-${var.environment}"
  path        = "/"
  description = "IAM policy for KMS Read Access from the Webhook task processor"
  policy      = data.aws_iam_policy_document.kms_read_access[0].json
}

# data "aws_iam_policy_document" "kms_write_access" {
#   count                   = local.use_kms_key != null ? 1 : 0
#   source_policy_documents = [data.aws_iam_policy_document.kms_read_access[0].json]
#   statement {
#     sid = "AllowKMSWriteAccess"
#     actions = [
#       "kms:Encrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey"
#     ]
#     resources = [local.kms_key_id]
#   }
# }

# resource "aws_iam_policy" "kms_write_access" {
#   count       = local.use_kms_key != null ? 1 : 0
#   name        = "connect-webhook-kms-write-${var.environment}"
#   path        = "/"
#   description = "IAM policy for KMS Write Access from the Webhook task processor"
#   policy      = data.aws_iam_policy_document.kms_write_access[0].json
# }