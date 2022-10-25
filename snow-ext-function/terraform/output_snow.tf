output "snowflake_api_aws_iam_user_arn" {
  value = join("", snowflake_api_integration.api_integration.*.api_aws_iam_user_arn)
}

output "snowflake_api_aws_external_id" {
  value = join("", snowflake_api_integration.api_integration.*.api_aws_external_id)
}

output "aws_api_gateway_deployment_invoke_url_demo" {
  value = module.external_function_demo.aws_api_gateway_deployment_invoke_url
}

output "aws_api_gateway_deployment_invoke_url_get_weather" {
  value = module.external_function_get_weather.aws_api_gateway_deployment_invoke_url
}
