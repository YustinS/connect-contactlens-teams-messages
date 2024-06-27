##################
# Webhook Function Function
##################
resource "aws_iam_role" "webhook_function_lambda_role" {
  name               = "${local.webhook_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.python_lambda_assume_role.json
}

data "aws_iam_policy_document" "webhook_function_lambda_logging" {
  #tfsec:ignore:AWS099 - Requires wildcarded at the given ARN location
  statement {
    sid = "AllowCWAccess"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.webhook_function_logs.arn}:*"]
  }
}

resource "aws_iam_policy" "webhook_function_lambda_logging" {
  name        = "${local.webhook_function_name}-lambda-logging"
  path        = "/"
  description = "IAM policy for logging from ${local.webhook_function_name}"
  policy      = data.aws_iam_policy_document.webhook_function_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "webhook_function_lambda_logs" {
  role       = aws_iam_role.webhook_function_lambda_role.name
  policy_arn = aws_iam_policy.webhook_function_lambda_logging.arn
}

# KMS read access
resource "aws_iam_role_policy_attachment" "webhook_function_kms_read" {
  count      = local.use_kms_key ? 1 : 0
  role       = aws_iam_role.webhook_function_lambda_role.name
  policy_arn = aws_iam_policy.kms_read_access[0].arn
}

# DDB Access
data "aws_iam_policy_document" "webhook_function_lambda_ssm" {
  statement {
    sid = "AllowAccess"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      data.aws_ssm_parameter.webhook_url_parameter.arn
    ]
  }
}

resource "aws_iam_policy" "webhook_function_lambda_ssm" {
  name        = "${local.webhook_function_name}-lambda-ssm-access"
  path        = "/"
  description = "IAM policy for SSM Access from ${local.webhook_function_name}"
  policy      = data.aws_iam_policy_document.webhook_function_lambda_ssm.json
}


resource "aws_iam_role_policy_attachment" "webhook_function_lambda_ssm" {
  role       = aws_iam_role.webhook_function_lambda_role.name
  policy_arn = aws_iam_policy.webhook_function_lambda_ssm.arn
}