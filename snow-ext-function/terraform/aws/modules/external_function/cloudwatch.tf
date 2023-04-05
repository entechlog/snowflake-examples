resource "aws_cloudwatch_log_group" "snow_ext_function_lambda" {

  for_each = toset(var.snowflake_ext_function_name)

  name              = "/aws/lambda/${aws_lambda_function.snow_ext_function[each.key].function_name}"
  retention_in_days = 90

}

resource "aws_cloudwatch_log_group" "snow_ext_function_api_gateway" {

  for_each = toset(var.snowflake_ext_function_name)

  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.lambda_proxy[each.key].id}/${lower(var.env_code)}"
  retention_in_days = 90

}