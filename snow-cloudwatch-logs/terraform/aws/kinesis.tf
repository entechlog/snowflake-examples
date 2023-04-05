resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_logs" {
  name        = "${local.resource_name_prefix}-lambda-cloudwatch-logs-to-s3-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_to_s3_delivery_role.arn
    bucket_arn = aws_s3_bucket.cloudwatch_logs.arn

    buffer_size        = 64
    buffer_interval    = 60
    compression_format = "UNCOMPRESSED"

    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

  }
}
