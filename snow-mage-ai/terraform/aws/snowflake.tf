# This policy document allows Snowflake to assume the IAM role.
data "aws_iam_policy_document" "snowflake_assume_role" {

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.snowflake__aws_iam_user_arn}"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.optional_snowflake__storage_aws_external_id}"]
    }
  }
}

# IAM role that Snowflake will assume.
resource "aws_iam_role" "snowflake" {
  name               = "${local.resource_name_prefix}-snowflake-role"
  description        = "IAM role used by Snowflake to connect to S3"
  assume_role_policy = data.aws_iam_policy_document.snowflake_assume_role.json
}

# Output the ARN of the Snowflake IAM role.
output "AWS_IAM_ROLE_ARN_SNOWFLAKE" {
  value = aws_iam_role.snowflake.arn
}

# Placeholder for Snowflake's AWS IAM user ARN.
# Acquired from running the Snowflake command: DESCRIBE integration <integration-name>
variable "optional_snowflake__aws_iam_user_arn" {
  type        = string
  description = "The AWS IAM user arn from Snowflake"
  default     = null
}

# Placeholder for Snowflake's AWS external ID.
# Acquired from running the Snowflake command: DESCRIBE integration <integration-name>
variable "optional_snowflake__storage_aws_external_id" {
  type        = string
  description = "The AWS external ID from Snowflake"
  default     = "12345"
}
