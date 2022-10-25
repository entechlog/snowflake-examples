data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "null_resource" "copy_files" {
  provisioner "local-exec" {
    command = "rm -rf uploads/lambda/${lower(var.snowflake_ext_function_name)}/target && mkdir uploads/lambda/${lower(var.snowflake_ext_function_name)}/target && cp uploads/lambda/${lower(var.snowflake_ext_function_name)}/${lower(var.snowflake_ext_function_name)}.py uploads/lambda/${lower(var.snowflake_ext_function_name)}/requirements.txt -t uploads/lambda/${lower(var.snowflake_ext_function_name)}/target"
  }

  triggers = {
    build_number = timestamp()
  }
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/requirements.txt -t uploads/lambda/${lower(var.snowflake_ext_function_name)}/target"
  }

  # triggers = {
  #   dependencies_versions = filemd5("uploads/lambda/${lower(var.snowflake_ext_function_name)}/requirements.txt")
  #   source_versions       = filemd5("uploads/lambda/${lower(var.snowflake_ext_function_name)}/${lower(var.snowflake_ext_function_name)}.py")
  # }

  triggers = {
    build_number = timestamp()
  }

  depends_on = [null_resource.copy_files]
}

data "archive_file" "snow_ext_function" {
  type        = "zip"
  source_dir  = "uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/"
  output_path = "uploads/lambda/${lower(var.snowflake_ext_function_name)}.zip"
  excludes    = ["uploads/lambda/.gitkeep", "__pycache__", "venv"]
  depends_on  = [null_resource.install_dependencies]
}

data "aws_iam_policy_document" "api_gateway_resource_policy" {
  statement {
    actions = [
      "execute-api:Invoke"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.iam_role_name_snow_ext_function}/snowflake"]
    }
    resources = [
      "${aws_api_gateway_rest_api.lambda_proxy.execution_arn}/${lower(var.env_code)}/POST/${lower(var.snowflake_ext_function_name)}"
    ]
  }
}