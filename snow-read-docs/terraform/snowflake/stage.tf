resource "snowflake_stage" "this" {
  name                = "DEMO_S3_STG"
  storage_integration = snowflake_storage_integration.this.id
  url                 = "${var.snowflake_storage_integration__storage_allowed_locations[0]}/response/"
  database            = snowflake_database.this.name
  schema              = snowflake_schema.this.name
  file_format         = "FORMAT_NAME = ${snowflake_database.this.name}.${snowflake_schema.this.name}.${snowflake_file_format.this.name}"
}