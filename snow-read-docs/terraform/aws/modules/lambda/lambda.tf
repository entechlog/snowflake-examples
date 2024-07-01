resource "aws_lambda_function" "lambda_function" {

  for_each = toset(var.lambda_function_name)

  function_name = replace("${local.resource_name_prefix}-${lower(each.key)}", "_", "-")

  filename         = data.archive_file.lambda_function[each.key].output_path
  source_code_hash = data.archive_file.lambda_function[each.key].output_base64sha256

  # Naming standard is file-name.function-name
  handler = "${lower(each.key)}.lambda_handler"
  runtime = "python3.9"
  timeout = "300"
  role    = aws_iam_role.lambda_exec.arn
}