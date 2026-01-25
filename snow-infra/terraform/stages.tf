# File format
resource "snowflake_file_format" "parquet_format" {
  database    = module.raw_db.database.name
  schema      = "UTIL"
  name        = "PARQUET_FORMAT"
  format_type = "PARQUET"

  depends_on = [module.raw_db.schemas]
}

# Stage
resource "snowflake_stage" "raw_data_parquet_stage" {
  database = module.raw_db.database.name
  schema   = "UTIL"
  name     = "PARQUET_STAGE"
  comment  = "Main stage for raw Parquet data"

  url                 = "s3://${lower(var.project_code)}-raw-ext-volume"
  storage_integration = snowflake_storage_integration.raw_data_storage_integration.name
  file_format         = "FORMAT_NAME = ${module.raw_db.database.name}.UTIL.PARQUET_FORMAT"

  depends_on = [module.raw_db.schemas, snowflake_file_format.parquet_format]
}

# Grant USAGE on the FILE FORMAT
resource "snowflake_grant_privileges_to_account_role" "file_format_usage" {
  privileges        = ["USAGE"]
  account_role_name = "${upper(var.project_code)}_PIPE_ADMIN_ROLE"

  on_schema_object {
    object_type = "FILE FORMAT"
    object_name = "${module.raw_db.database.name}.UTIL.PARQUET_FORMAT"
  }

  depends_on = [snowflake_file_format.parquet_format]
}

# Grant USAGE on the STAGE
resource "snowflake_grant_privileges_to_account_role" "stage_usage" {
  privileges        = ["USAGE"]
  account_role_name = "${upper(var.project_code)}_PIPE_ADMIN_ROLE"

  on_schema_object {
    object_type = "STAGE"
    object_name = "${module.raw_db.database.name}.UTIL.PARQUET_STAGE"
  }

  depends_on = [snowflake_stage.raw_data_parquet_stage]
}
