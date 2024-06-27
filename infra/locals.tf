locals {
  account_id = data.aws_caller_identity.current.account_id

  eventbridge_rule_name = "${var.resource_shortname}-contactlens-rules-triggered-${var.environment}"

  use_kms_key           = var.encryption_configuration.use_cmk && var.encryption_configuration.cmk_id != null ? true : false
  kms_key_id            = var.encryption_configuration.use_cmk && var.encryption_configuration.cmk_id != null ? data.aws_kms_key.custom_key[0].arn : null
  webhook_function_name = "${var.resource_shortname}-eventbridge-teams-webhook-${var.environment}"
}

data "aws_kms_key" "custom_key" {
  count  = var.encryption_configuration.use_cmk ? 1 : 0
  key_id = var.encryption_configuration.cmk_id
}

data "aws_connect_instance" "connect_instance" {
  instance_alias = var.aws_connect_instance_alias
}

data "aws_caller_identity" "current" {}

# data "aws_partition" "current" {}

data "aws_ssm_parameter" "webhook_url_parameter" {
  name            = var.webhook_url_parameter_path
  with_decryption = false
}