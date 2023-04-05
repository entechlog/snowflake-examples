resource "aws_iam_role" "lambda_exec" {
  name        = "${var.resource_name_prefix}-lambda-exec-role"
  description = "IAM role used by AWS lambda to access other AWS services"
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

resource "aws_iam_role_policy" "lambda_exec" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role" "snow_ext_function" {
  name        = "${var.resource_name_prefix}-snow-ext-function-role"
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

resource "aws_iam_role" "cloudwatch" {
  name        = "${var.resource_name_prefix}-api-cloudwatch-role"
  description = "IAM role used by API gateway to write logs to cloudwatch"
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

resource "aws_iam_role_policy" "cloudwatch" {
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}