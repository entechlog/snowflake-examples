resource "snowflake_api_integration" "api_integration" {
  name             = "aws_integration"
  api_provider     = "aws_api_gateway"
  api_aws_role_arn = aws_iam_role.snow_ext_function.arn
  api_allowed_prefixes = [
    "${module.external_function_demo.aws_api_gateway_deployment_invoke_url}/",
    "${module.external_function_get_weather.aws_api_gateway_deployment_invoke_url}/"
  ]
  enabled = true
}