resource "aws_lambda_function" "snow_ext_function" {
  function_name = "${local.resource_name_prefix}-${lower(var.snowflake_ext_function_name)}-function"

  filename         = data.archive_file.snow_ext_function.output_path
  source_code_hash = data.archive_file.snow_ext_function.output_base64sha256

  # Naming standard is file-name.function-name
  handler = "${lower(var.snowflake_ext_function_name)}.lambda_handler"
  runtime = "python3.8"
  role    = aws_iam_role.lambda_exec.arn
}

# Permission
resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snow_ext_function.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.lambda_proxy.execution_arn}/*/*"
}
