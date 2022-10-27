resource "snowflake_api_integration" "api_integration" {

  name             = var.snowflake_api_integration_name
  api_provider     = "aws_api_gateway"
  api_aws_role_arn = aws_iam_role.snow_ext_function.arn


  api_allowed_prefixes = [for each in var.snowflake_ext_function_name :
    "${aws_api_gateway_deployment.lambda_proxy[each].invoke_url}/"
  ]

  enabled = true
}