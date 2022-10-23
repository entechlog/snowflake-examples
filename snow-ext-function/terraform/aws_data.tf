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

data "archive_file" "snow_ext_function" {
  type        = "zip"
  source_dir  = "uploads/lambda/${lower(var.snowflake_ext_function_name)}/"
  output_path = "uploads/lambda/${lower(var.snowflake_ext_function_name)}.zip"
  excludes    = ["uploads/lambda/.gitkeep"]
}

data "aws_iam_policy_document" "api_gateway_resource_policy" {
  statement {
    actions = [
      "execute-api:Invoke"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.snow_ext_function.name}/snowflake"]
    }
    resources = [
      "${aws_api_gateway_rest_api.lambda_proxy.execution_arn}/*/POST/"
    ]
  }
}