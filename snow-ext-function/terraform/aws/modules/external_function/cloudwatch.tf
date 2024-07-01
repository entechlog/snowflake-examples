# -------------------------------------------------------------------------
# CloudWatch Log Group for Lambda Function
# -------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "external_function_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.external_function_lambda.function_name}"
  retention_in_days = 90
}

# -------------------------------------------------------------------------
# CloudWatch Log Group for API Gateway Execution Logs
# -------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "external_function_api_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.external_function_api.id}/${lower(var.env_code)}"
  retention_in_days = 90
}
