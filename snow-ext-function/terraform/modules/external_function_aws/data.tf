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

  for_each = toset(var.snowflake_ext_function_name)

  provisioner "local-exec" {
    command = <<EOT
    rm -rf ../../uploads/lambda/${lower(each.key)}/target
    mkdir ../../uploads/lambda/${lower(each.key)}/target
    cp ../../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py -t ../../uploads/lambda/${lower(each.key)}/target
    cp ../../uploads/lambda/${lower(each.key)}/requirements.txt -t ../../uploads/lambda/${lower(each.key)}/target
    EOT
  }

  triggers = {
    dependencies_versions = filemd5("../../uploads/lambda/${lower(each.key)}/requirements.txt")
    source_versions       = filemd5("../../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
  }
}

resource "null_resource" "install_dependencies" {

  for_each = toset(var.snowflake_ext_function_name)

  provisioner "local-exec" {
    command = <<EOT
    pip install -r ../../uploads/lambda/${lower(each.key)}/target/requirements.txt -t ../../uploads/lambda/${lower(each.key)}/target
    EOT
  }

  triggers = {
    dependencies_versions = filemd5("../../uploads/lambda/${lower(each.key)}/requirements.txt")
    source_versions       = filemd5("../../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
  }

  # triggers = {
  #   build_number = timestamp()
  # }

  depends_on = [null_resource.copy_files]
}

data "archive_file" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  type        = "zip"
  source_dir  = "../../uploads/lambda/${lower(each.key)}/target/"
  output_path = "../../uploads/lambda/${lower(each.key)}.zip"
  excludes    = ["../../uploads/lambda/.gitkeep", "__pycache__", "venv"]
  depends_on  = [null_resource.install_dependencies]
}

data "aws_iam_policy_document" "api_gateway_resource_policy" {

  for_each = toset(var.snowflake_ext_function_name)

  statement {
    actions = [
      "execute-api:Invoke"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.snow_ext_function.name}/snowflake"]
    }
    resources = [
      "${aws_api_gateway_rest_api.lambda_proxy[each.key].execution_arn}/${lower(var.env_code)}/POST/${lower(each.key)}"
    ]
  }
}