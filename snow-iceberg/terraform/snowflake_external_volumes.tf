# External Volume
resource "snowflake_external_volume" "raw_data_volume" {
  name         = local.external_volume_name
  allow_writes = true
  comment      = "External volume for raw data"
  storage_location {
    storage_location_name = "main-s3-location"
    storage_provider      = "S3"
    storage_base_url      = "s3://${module.external_volume_bucket.aws_s3_bucket__name[0]}/"
    storage_aws_role_arn  = aws_iam_role.external_volume_role.arn
  }
  depends_on = [aws_iam_role.external_volume_role]
}
# Storage Integration
resource "snowflake_storage_integration" "raw_data_s3_integration" {
  name    = local.storage_integration_name
  comment = "Storage integration for raw data S3 access"
  type    = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${module.external_volume_bucket.aws_s3_bucket__name[0]}/"]
  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.external_volume_role.arn
  depends_on = [aws_iam_role.external_volume_role]
}
# File format
resource "snowflake_file_format" "parquet_format" {
  database    = local.database_name
  schema      = "FAKER"
  name        = "PARQUET_FORMAT"
  format_type = "PARQUET"
}
# Stage
resource "snowflake_stage" "raw_data_parquet_stage" {
  database = local.database_name
  schema   = "FAKER"
  name     = "RAW_DATA_PARQUET_STG"
  comment  = "Main stage for raw Parquet data"
  url                 = "s3://${module.external_volume_bucket.aws_s3_bucket__name[0]}/"
  storage_integration = snowflake_storage_integration.raw_data_s3_integration.name
  file_format         = "FORMAT_NAME = ${local.database_name}.FAKER.${snowflake_file_format.parquet_format.name}"
  depends_on = [
    snowflake_storage_integration.raw_data_s3_integration,
    snowflake_file_format.parquet_format
  ]
}