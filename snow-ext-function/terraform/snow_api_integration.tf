resource "snowflake_api_integration" "api_integration" {
  name                 = "aws_integration"
  api_provider         = "aws_api_gateway"
  api_aws_role_arn     = aws_iam_role.snow_ext_function.arn
  api_allowed_prefixes = ["${aws_api_gateway_deployment.lambda_proxy.invoke_url}/"]
  enabled              = true
}