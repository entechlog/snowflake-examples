resource "snowflake_api_integration" "api_integration" {

  name             = var.snowflake_api_integration_name
  api_provider     = "aws_api_gateway"
  api_aws_role_arn = var.aws_iam_role__arn


  api_allowed_prefixes = var.aws_api_gateway_deployment__invoke_url

  enabled = true
}