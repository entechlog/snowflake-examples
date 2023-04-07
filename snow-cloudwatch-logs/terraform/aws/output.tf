output "aws_kinesis_firehose_delivery_stream__cloudwatch_logs__name" {
  value = aws_kinesis_firehose_delivery_stream.cloudwatch_logs.name
}

output "aws_s3_bucket__cloudwatch_logs__arn" {
  value = aws_s3_bucket.cloudwatch_logs.arn
}

output "aws_s3_bucket__cloudwatch_logs__id" {
  value = aws_s3_bucket.cloudwatch_logs.id
}

output "aws_iam_role__s3_to_snowflake_delivery_role__arn" {
  value = aws_iam_role.s3_to_snowflake_delivery_role.arn
}