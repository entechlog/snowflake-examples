resource "aws_sns_topic" "demo_bucket" {
  name = "${local.resource_name_prefix}-s3-event-notification-demo"
}

resource "aws_sns_topic_policy" "demo_bucket" {
  arn    = aws_sns_topic.demo_bucket.arn
  policy = data.aws_iam_policy_document.lambda_sns_policy_document.json
}

resource "aws_sns_topic_subscription" "demo_bucket" {

  for_each = toset(module.lambda_function.aws_lambda_function__arn)

  topic_arn = aws_sns_topic.demo_bucket.arn
  protocol  = "lambda"
  endpoint  = each.key
}