resource "snowflake_file_format" "this" {
  name          = "DEMO_JSON_FF"
  database      = snowflake_database.this.name
  schema        = snowflake_schema.this.name
  format_type   = "JSON"
  compression   = "AUTO"
  binary_format = "UTF-8"
}