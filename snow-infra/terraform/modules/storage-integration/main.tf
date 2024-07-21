resource "snowflake_storage_integration" "storage_integration" {
  name                      = var.name
  comment                   = var.comment
  type                      = "EXTERNAL_STAGE"
  enabled                   = var.enabled
  storage_allowed_locations = var.storage_allowed_locations
  storage_blocked_locations = var.storage_blocked_locations
  storage_provider          = var.storage_provider
  storage_aws_role_arn      = var.storage_aws_role_arn
}

resource "snowflake_integration_grant" "integration_grant" {
  integration_name = snowflake_storage_integration.storage_integration.name
  privilege        = "USAGE"
  roles            = var.roles

  with_grant_option = false
}
