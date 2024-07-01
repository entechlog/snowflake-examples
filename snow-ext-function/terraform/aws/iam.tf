# -------------------------------------------------------------------------
# IAM role for Lambda execution
# -------------------------------------------------------------------------
resource "aws_iam_role" "external_function_lambda_exec_role" {
  name        = "${local.resource_name_prefix}-lambda-exec-role"
  description = "IAM role used by AWS Lambda to access other AWS services"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}

# -------------------------------------------------------------------------
# IAM role policy for Lambda execution
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "external_function_lambda_exec_policy" {
  role   = aws_iam_role.external_function_lambda_exec_role.id
  policy = data.aws_iam_policy_document.external_function_lambda_execution_policy.json
}

# -------------------------------------------------------------------------
# IAM role for Snowflake external function
# -------------------------------------------------------------------------
resource "aws_iam_role" "external_function_snowflake_role" {
  name        = "${local.resource_name_prefix}-snowflake-ext-function-role"
  description = "IAM role used by Snowflake external function to make API Gateway/Lambda call"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "AWS" : "${local.api_aws_iam_user_arn}"
          },
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : "${var.snowflake_api_aws_external_id}"
            }
          }
        }
      ]
    }
  )
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"]
}

# -------------------------------------------------------------------------
# IAM role for API Gateway to write logs to CloudWatch
# -------------------------------------------------------------------------
resource "aws_iam_role" "external_function_cloudwatch_role" {
  name        = "${local.resource_name_prefix}-api-cloudwatch-role"
  description = "IAM role used by API Gateway to write logs to CloudWatch"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "apigateway.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

# -------------------------------------------------------------------------
# IAM role policy for API Gateway to write logs to CloudWatch
# -------------------------------------------------------------------------
resource "aws_iam_role_policy" "external_function_cloudwatch_policy" {
  role   = aws_iam_role.external_function_cloudwatch_role.id
  policy = data.aws_iam_policy_document.external_function_cloudwatch_policy.json
}