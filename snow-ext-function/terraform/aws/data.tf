# -------------------------------------------------------------------------
# Data source to get the current AWS caller identity
# -------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------------
# Data source to get the current AWS region
# -------------------------------------------------------------------------
data "aws_region" "current" {}

# -------------------------------------------------------------------------
# IAM policy document for Lambda execution policy
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "external_function_lambda_execution_policy" {
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

# -------------------------------------------------------------------------
# IAM policy document for CloudWatch policy
# -------------------------------------------------------------------------
data "aws_iam_policy_document" "external_function_cloudwatch_policy" {
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