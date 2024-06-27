resource "aws_lambda_function" "queue_process" {
  depends_on = [
    aws_cloudwatch_log_group.webhook_function_logs
  ]

  filename         = "${path.module}/../code/eventbridge-webhook-processor/eventbridge-webhook-processor.zip"
  source_code_hash = filebase64sha256("${path.module}/../code/eventbridge-webhook-processor/eventbridge-webhook-processor.zip")

  function_name = local.webhook_function_name
  role          = aws_iam_role.webhook_function_lambda_role.arn
  handler       = "src/app.lambda_handler"
  runtime       = "nodejs20.x"
  memory_size   = 128
  timeout       = 30
  kms_key_arn   = local.kms_key_id


  tags = {
    "Name"        = local.webhook_function_name,
    "Application" = "eventbridge-to-teams"
  }

  environment {
    variables = {
      ENVIRONMENT    = var.environment
      PARAMETER_NAME = var.webhook_url_parameter_path
      CONNECT_URL    = "${var.aws_connect_instance_alias}.${var.amazon_connect_instance_domain}"
    }
  }
}

resource "aws_cloudwatch_log_group" "webhook_function_logs" {
  name = "/aws/lambda/${local.webhook_function_name}"
  # retention_in_days = var.log_retention_days
  kms_key_id = local.kms_key_id
}

resource "aws_lambda_permission" "webhook_function_invoke_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.queue_process.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.contactlens_eventbridge_rule.arn
}
