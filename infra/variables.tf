variable "aws_region" {
  description = "AWS Region that this is run in"
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "The environment this is running against"
}

variable "aws_profile" {
  description = "The named profile used to deploy the resources"
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(any)
  default     = {}
}

variable "resource_shortname" {
  description = "Shortname for resources, that will be used with ensuring naming is consistent. Used as prefix for deployed resources"
  type        = string
}

variable "log_retention_days" {
  description = "The length of time to maintain the logs for"
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0], var.log_retention_days)
    error_message = "Please ensure that 'log_retention_days' is one of the values listed in description."
  }
}

variable "aws_connect_instance_alias" {
  description = "Alias name for the Amazin Connect instance"
  type        = string
}

variable "encryption_configuration" {
  description = "The encryption configuration to be used in the account (if applicable)"
  type = object({
    use_cmk = bool   # Whether to use a CMK.
    cmk_id  = string # ID for the CMK we want to use
  })

  default = {
    use_cmk = false
    cmk_id  = null
  }
}

variable "webhook_url_parameter_path" {
  description = "The SSM Parameter Store path that the webhook URL is stored at"
}

variable "amazon_connect_instance_domain" {
  description = "The domain that Amazon Connect runs on. Default should be used, however legacy domains do exist"
  default     = "my.connect.alias"
}