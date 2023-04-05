resource "snowflake_storage_integration" "this" {

  name                      = "${upper(var.project_code)}_CWL_STR_S3_INTG"
  storage_provider          = "S3"
  storage_allowed_locations = var.snowflake_storage_integration__storage_allowed_locations
  storage_aws_role_arn      = var.snowflake_storage_integration__storage_aws_role_arn

  enabled = true
}