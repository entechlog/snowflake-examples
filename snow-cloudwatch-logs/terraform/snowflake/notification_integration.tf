# resource "snowflake_notification_integration" "cloudwatch_logs" {
#   name      = "${upper(var.project_code)}_CWL_NOT_SQS_INTG"
#   enabled   = true
#   type      = "QUEUE"
#   direction = "OUTBOUND"

#   notification_provider = "AWS_SQS"
#   aws_sqs_arn           = var.snowflake_notification_integration__aws_sqs_arn
#   aws_sqs_role_arn      = var.snowflake_notification_integration__aws_sqs_role_arn
# }