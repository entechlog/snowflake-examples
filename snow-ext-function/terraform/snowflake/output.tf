# -------------------------------------------------------------------------
# Outputs for Snowflake API Integration
# -------------------------------------------------------------------------

# ARN of the AWS IAM user for the Snowflake API integration
output "snowflake_api_integration_api_aws_iam_user_arn" {
  description = "The ARN of the AWS IAM user for the Snowflake API integration"
  value       = snowflake_api_integration.external_function_api_integration.api_aws_iam_user_arn
}

# External ID for the Snowflake API integration
output "snowflake_api_integration_api_aws_external_id" {
  description = "The external ID for the Snowflake API integration"
  value       = snowflake_api_integration.external_function_api_integration.api_aws_external_id
}
