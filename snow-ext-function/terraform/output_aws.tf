# AWS | IAM

output "iam_role_name_snow_ext_function" {
  description = "IAM role name used by Snowflake external function to make API Gateway/Lambda call"
  value       = join("", aws_iam_role.snow_ext_function.*.name)
}

output "iam_role_arn_snow_ext_function" {
  description = "IAM role arn used by Snowflake external function to make API Gateway/Lambda call"
  value       = join("", aws_iam_role.snow_ext_function.*.arn)
}