output "snowflake_database__name" {
  value = join("", snowflake_database.this.*.name)
}

output "snowflake_schema__name" {
  value = join("", snowflake_schema.this.*.name)
}

output "snowflake_stage__name" {
  value = join("", snowflake_stage.this.*.name)
}

output "snowflake_file_format__name" {
  value = join("", snowflake_file_format.this.*.name)
}

output "snowflake_storage_integration__storage_aws_iam_user_arn" {
  value = join("", snowflake_storage_integration.this.*.storage_aws_iam_user_arn)
}

output "snowflake_storage_integration__storage_aws_external_id" {
  value = join("", snowflake_storage_integration.this.*.storage_aws_external_id)
}

output "snowflake_pipe__notification_channel" {
  value = snowflake_pipe.cloudwatch_logs.notification_channel
}