data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/lambda/external_function/*",
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }
}

resource "null_resource" "copy_files" {

  for_each = toset(var.snowflake_ext_function_name)

  provisioner "local-exec" {
    command = "rm -rf ../uploads/lambda/${lower(each.key)}/target && mkdir ../uploads/lambda/${lower(each.key)}/target && cp ../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py -t ../uploads/lambda/${lower(each.key)}/target/ && cp ../uploads/lambda/${lower(each.key)}/requirements.txt -t ../uploads/lambda/${lower(each.key)}/target/"
  }

  triggers = {
    dependencies_versions = filemd5("../uploads/lambda/${lower(each.key)}/requirements.txt")
    source_versions       = filemd5("../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
  }
  # triggers = {
  #   build_number = timestamp()
  # }
}

resource "null_resource" "install_dependencies" {

  for_each = toset(var.snowflake_ext_function_name)

  provisioner "local-exec" {
    command = "pip install -r ../uploads/lambda/${lower(each.key)}/target/requirements.txt -t ../uploads/lambda/${lower(each.key)}/target"
  }

  triggers = {
    dependencies_versions = filemd5("../uploads/lambda/${lower(each.key)}/requirements.txt")
    source_versions       = filemd5("../uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
  }

  # triggers = {
  #   build_number = timestamp()
  # }

  depends_on = [null_resource.copy_files]
}

data "archive_file" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  type        = "zip"
  source_dir  = "../uploads/lambda/${lower(each.key)}/target/"
  output_path = "../uploads/lambda/${lower(each.key)}.zip"
  excludes    = ["../uploads/lambda/.gitkeep", "__pycache__", "venv"]
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

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}