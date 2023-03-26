output "aws_lambda_function__arn" {
  value = module.lambda_function.aws_lambda_function__arn
}

output "aws_lambda_function__invoke_arn" {
  value = module.lambda_function.aws_lambda_function__invoke_arn
}

output "aws_lambda_function__function_name" {
  value = module.lambda_function.aws_lambda_function__function_name
}

output "aws_s3_bucket__id" {
  value = module.s3.aws_s3_bucket__id
}

output "aws_iam_role__arn" {
  description = "IAM role arn used by Snowflake"
  value       = module.s3.aws_s3_bucket__arn
}

output "aws_sns_topic__arn" {
  value = aws_sns_topic.demo_bucket.arn
}