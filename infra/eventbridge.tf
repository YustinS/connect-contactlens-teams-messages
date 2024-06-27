resource "aws_cloudwatch_event_rule" "contactlens_eventbridge_rule" {
  name        = local.eventbridge_rule_name
  description = "Contact Lens Rule Triggered - ${var.resource_shortname} - ${var.environment}"

  event_pattern = jsonencode({
    "detail-type" = [
      "Contact Lens Realtime Rules Matched",
      "Contact Lens Post Call Rules Matched",
      "Contact Lens Realtime Chat Rules Matched",
      "Contact Lens Post Chat Rules Matched",
      "Metrics Rules Matched"
    ]
    "source" = ["aws.connect"]
    "detail" = {
      "instanceArn" = ["${data.aws_connect_instance.connect_instance.arn}"]
    }
  })
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "contactlens_eventbridge_rule_function" {
  rule      = aws_cloudwatch_event_rule.contactlens_eventbridge_rule.name
  target_id = "${var.resource_shortname}-contactlens-function-trigger-${var.environment}"
  arn       = aws_lambda_function.queue_process.arn
}

# "actionName" = [
#   { "prefix" = "" }
# ]