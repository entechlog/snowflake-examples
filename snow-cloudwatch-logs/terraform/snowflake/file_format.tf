resource "snowflake_file_format" "this" {
  name             = "${upper(var.project_code)}_CWL_JSON_FF"
  database         = snowflake_database.this.name
  schema           = snowflake_schema.this.name
  format_type      = "JSON"
  compression      = "AUTO"
  binary_format    = "UTF-8"
  date_format      = "AUTO"
  time_format      = "AUTO"
  timestamp_format = "AUTO"
}