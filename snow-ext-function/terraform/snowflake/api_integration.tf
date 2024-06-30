resource "snowflake_api_integration" "external_function_api_integration" {
  name                 = "${upper(var.env_code)}_${upper(var.project_code)}_DAT_AWS_API_INTG"
  api_provider         = "aws_api_gateway"
  api_aws_role_arn     = var.aws_iam_role_arn
  api_allowed_prefixes = [for key, url in var.aws_api_gateway_deployment_invoke_url : url]
  enabled              = var.api_integration_enabled
}
