resource "aws_cloudwatch_log_group" "external_function_lambda_log_group" {
  name              = "/aws/lambda/${var.snowflake_ext_function_name}_lambda"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "external_function_api_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.external_function_api.id}/${lower(var.env_code)}"
  retention_in_days = 90
}
