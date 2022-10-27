output "snowflake_api_integration__api_aws_iam_user_arn" {
  value = join("", snowflake_api_integration.api_integration.*.api_aws_iam_user_arn)
}

output "snowflake_api_integration__api_aws_external_id" {
  value = join("", snowflake_api_integration.api_integration.*.api_aws_external_id)
}