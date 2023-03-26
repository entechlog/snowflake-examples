resource "snowflake_storage_integration" "this" {

  name                      = var.snowflake_storage_integration__name
  storage_provider          = "S3"
  storage_allowed_locations = var.snowflake_storage_integration__storage_allowed_locations
  storage_aws_role_arn      = var.aws_iam_role__arn

  enabled = true
}