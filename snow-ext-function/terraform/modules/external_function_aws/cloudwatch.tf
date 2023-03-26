resource "aws_cloudwatch_log_group" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  name              = "/aws/lambda/${aws_lambda_function.snow_ext_function[each.key].function_name}"
  retention_in_days = 90

}