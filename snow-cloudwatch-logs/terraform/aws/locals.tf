locals {
  account_id                           = data.aws_caller_identity.current.account_id
  resource_name_prefix                 = var.use_env_code == true ? "${lower(var.env_code)}-${lower(var.project_code)}" : "${lower(var.project_code)}"
  snowflake__aws_iam_user_arn          = coalesce(var.snowflake__aws_iam_user_arn, data.aws_caller_identity.current.arn)
  snowflake_pipe__notification_channel = coalesce("${var.snowflake_pipe__notification_channel}", "arn:aws:sqs:${data.aws_region.current.name}:${local.account_id}:${local.resource_name_prefix}-cwl-s3-event-notification-queue")
}
