locals {
  api_aws_iam_user_arn = coalesce(var.snowflake_api_aws_iam_user_arn, data.aws_caller_identity.current.arn)
  resource_name_prefix = var.use_env_code == "true" ? "${lower(var.env_code)}-${lower(var.project_code)}" : "${lower(var.project_code)}"
}
