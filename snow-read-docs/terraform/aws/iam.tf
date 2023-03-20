resource "aws_iam_role" "snow_s3_intg" {
  name        = "${local.resource_name_prefix}-snow-s3-intg-role"
  description = "IAM role used by Snowflake to connect to S3"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "AWS" : "${local.snowflake_storage_aws_iam_user_arn}"
          },
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : "${var.snowflake_storage_aws_external_id}"
            }
          }
        }
      ]
    }
  )
}