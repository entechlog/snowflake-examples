resource "aws_kms_key" "kms_lambda" {
  description = "${local.resource_name_prefix}-lambda"

  tags = merge(local.tags, {
    Name        = "${local.resource_name_prefix}-lambda"
    Environment = "${upper(var.env_code)}"
  })
}

resource "aws_kms_alias" "kms_lambda" {
  name          = "alias/lambda/${local.resource_name_prefix}-lambda"
  target_key_id = aws_kms_key.kms_lambda.key_id
}