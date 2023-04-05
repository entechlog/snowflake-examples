resource "aws_cloudwatch_log_subscription_filter" "lambda_cloudwatch_logs" {
  name            = "${local.resource_name_prefix}-lambda-cloudwatch-logs-to-s3-subscription"
  log_group_name  = "/aws/lambda/entechlog-demo-function"
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_logs.arn
  filter_pattern  = ""
  role_arn        = aws_iam_role.cloudwatch_to_firehose_delivery_role.arn
}