# -------------------------------------------------------------------------
# Lambda function for the external function
# -------------------------------------------------------------------------
resource "aws_lambda_function" "external_function_lambda" {
  function_name = replace("${var.resource_name_prefix}-${lower(var.snowflake_ext_function_name)}", "_", "-")

  filename         = data.archive_file.external_function_archive.output_path
  source_code_hash = data.archive_file.external_function_archive.output_base64sha256

  # Naming standard is file-name.function-name
  handler = "${lower(var.snowflake_ext_function_name)}.lambda_handler"
  runtime = "python3.8"
  timeout = 900
  role    = var.lambda_exec_role_arn

  environment {
    variables = var.aws_lambda_function__environment_variables
  }
}

# -------------------------------------------------------------------------
# Lambda permission for API Gateway to invoke the function
# -------------------------------------------------------------------------
resource "aws_lambda_permission" "external_function_apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.external_function_lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.external_function_api.execution_arn}/*/*"
}