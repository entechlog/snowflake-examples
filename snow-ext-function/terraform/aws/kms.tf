# -------------------------------------------------------------------------
# KMS key for AWS Lambda
# -------------------------------------------------------------------------
resource "aws_kms_key" "external_function_kms_lambda" {
  description = "KMS key used by AWS Lambda"

  tags = merge(local.tags, {
    Name        = "${local.resource_name_prefix}-lambda"
    Environment = "${upper(var.env_code)}"
  })
}

# -------------------------------------------------------------------------
# KMS alias for AWS Lambda
# -------------------------------------------------------------------------
resource "aws_kms_alias" "external_function_kms_lambda_alias" {
  name          = "alias/lambda/${local.resource_name_prefix}-lambda"
  target_key_id = aws_kms_key.external_function_kms_lambda.key_id
}