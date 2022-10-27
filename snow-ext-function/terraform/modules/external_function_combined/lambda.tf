resource "aws_lambda_function" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  function_name = replace("${local.resource_name_prefix}-${lower(each.key)}-function", "_", "-")

  filename         = data.archive_file.snow_ext_function[each.key].output_path
  source_code_hash = data.archive_file.snow_ext_function[each.key].output_base64sha256

  # Naming standard is file-name.function-name
  handler = "${lower(each.key)}.lambda_handler"
  runtime = "python3.8"
  role    = aws_iam_role.lambda_exec.arn
}

# Permission
resource "aws_lambda_permission" "apigw" {

  for_each = toset(var.snowflake_ext_function_name)

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snow_ext_function[each.key].arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.lambda_proxy[each.key].execution_arn}/*/*"
}
