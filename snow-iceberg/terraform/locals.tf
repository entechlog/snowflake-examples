locals {
  # AWS resource naming (lowercase-with-hyphens)
  aws_resource_prefix = var.use_env_code ? "${lower(var.env_code)}-${lower(var.project_code)}" : lower(var.project_code)

  # Snowflake resource naming (UPPERCASE_WITH_UNDERSCORES)
  snowflake_resource_prefix = "${upper(var.env_code)}_${upper(var.project_code)}"

  # Iceberg and Glue specific naming
  iceberg_catalog_integration_name = "${local.snowflake_resource_prefix}_ICEBERG_CATALOG_INT"
  database_name                    = "${local.snowflake_resource_prefix}_RAW_DB"

  # External Volumes specific naming
  external_volume_bucket_name = "${local.aws_resource_prefix}-raw-ext-volume"
  external_volume_name        = "${local.snowflake_resource_prefix}_RAW_EXTERNAL_VOLUME"
  storage_integration_name    = "${local.snowflake_resource_prefix}_RAW_STORAGE_INT"

  # Common tags
  common_tags = {
    Environment = upper(var.env_code)
    Project     = "${upper(var.project_code)}-ICEBERG-DEMO-EXT-VOLUME"
    ManagedBy   = "terraform"
  }
}