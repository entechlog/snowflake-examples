locals {
  account_id                  = data.aws_caller_identity.current.account_id
  resource_name_prefix        = var.optional_use_env_code_flag == true ? "${lower(var.required_env_code)}-${lower(var.required_project_code)}-${lower(var.required_app_code)}" : "${lower(var.required_project_code)}-${lower(var.required_app_code)}"
  snowflake__aws_iam_user_arn = coalesce(var.optional_snowflake__aws_iam_user_arn, data.aws_caller_identity.current.arn)
}