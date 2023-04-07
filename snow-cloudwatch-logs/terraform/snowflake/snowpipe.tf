resource "snowflake_pipe" "cloudwatch_logs" {
  database = snowflake_database.this.name
  schema   = snowflake_schema.this.name
  name     = "${upper(var.project_code)}_CWL_PIPE"

  copy_statement = "copy into ${snowflake_database.this.name}.${snowflake_schema.this.name}.${snowflake_table.this.name} from (select metadata$filename AS file_name, metadata$file_row_number AS file_row_number, metadata$file_content_key AS file_content_key, metadata$file_last_modified AS file_last_modified, $1 AS cloudwatch_log from @${snowflake_database.this.name}.${snowflake_schema.this.name}.${upper(var.project_code)}_CWL_S3_STG (file_format => ${snowflake_database.this.name}.${snowflake_schema.this.name}.${upper(var.project_code)}_CWL_JSON_FF))"
  auto_ingest    = true
  #   integration    = snowflake_notification_integration.cloudwatch_logs.name
}

