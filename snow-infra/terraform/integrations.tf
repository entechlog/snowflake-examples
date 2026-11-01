

# Raw Integration
resource "snowflake_storage_integration" "raw_data_storage_integration" {
  name    = "${upper(var.env_code)}_${upper(var.project_code)}_RAW_DATA_STORAGE_INTEGRATION"
  comment = "Storage Integration for Raw Data S3 Buckets"
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider     = "S3"
  storage_aws_role_arn = var.storage_integration_aws_iam_role_arn
  storage_allowed_locations = [
    "s3://${lower(var.project_code)}-raw-ext-volume",
    "s3://${lower(var.project_code)}-raw-data"
  ]

}