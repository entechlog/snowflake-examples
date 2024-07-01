data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -------------------------------------------------------------------------
# Local-exec provisioner to copy Lambda function files
# -------------------------------------------------------------------------
resource "null_resource" "external_function_copy_files" {
  provisioner "local-exec" {
    command = "rm -rf ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target && mkdir ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target && cp ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/${lower(var.snowflake_ext_function_name)}.py -t ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/ && cp ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/requirements.txt -t ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/"
  }

  triggers = {
    dependencies_versions = filemd5("../uploads/lambda/${lower(var.snowflake_ext_function_name)}/requirements.txt")
    source_versions       = filemd5("../uploads/lambda/${lower(var.snowflake_ext_function_name)}/${lower(var.snowflake_ext_function_name)}.py")
  }
}

# -------------------------------------------------------------------------
# Local-exec provisioner to install Lambda function dependencies
# -------------------------------------------------------------------------
resource "null_resource" "external_function_install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/requirements.txt -t ../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target"
  }

  triggers = {
    dependencies_versions = filemd5("../uploads/lambda/${lower(var.snowflake_ext_function_name)}/requirements.txt")
    source_versions       = filemd5("../uploads/lambda/${lower(var.snowflake_ext_function_name)}/${lower(var.snowflake_ext_function_name)}.py")
  }

  depends_on = [null_resource.external_function_copy_files]
}

# -------------------------------------------------------------------------
# Create an archive of the Lambda function
# -------------------------------------------------------------------------
data "archive_file" "external_function_archive" {
  type        = "zip"
  source_dir  = "../uploads/lambda/${lower(var.snowflake_ext_function_name)}/target/"
  output_path = "../uploads/lambda/${lower(var.snowflake_ext_function_name)}.zip"
  excludes    = ["../uploads/lambda/.gitkeep", "__pycache__", "venv"]
  depends_on  = [null_resource.external_function_install_dependencies]
}

# -------------------------------------------------------------------------
# IAM policy document for API Gateway resource policy
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "external_function_api_gateway_resource_policy" {
  statement {
    actions = [
      "execute-api:Invoke"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.lambda_exec_role_name}/snowflake"]
    }
    resources = [
      "${aws_api_gateway_rest_api.external_function_api.execution_arn}/${lower(var.env_code)}/POST/${lower(var.snowflake_ext_function_name)}"
    ]
  }
}