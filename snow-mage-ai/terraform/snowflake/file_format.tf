resource "snowflake_file_format" "json" {
  name             = "${upper(local.resource_prefix_with_env)}_CRICSHEET_JSON_FF"
  database         = module.raw_db.database.name
  schema           = "CRICSHEET"
  format_type      = "JSON"
  compression      = "AUTO"
  binary_format    = "'UTF-8'"
  date_format      = "AUTO"
  time_format      = "AUTO"
  timestamp_format = "AUTO"
}

resource "snowflake_file_format" "csv" {
  name                         = "${upper(local.resource_prefix_with_env)}_CRICSHEET_CSV_FF"
  database                     = module.raw_db.database.name
  schema                       = "CRICSHEET"
  format_type                  = "CSV"
  compression                  = "AUTO"
  binary_format                = "'UTF-8'"
  encoding                     = "UTF8"
  date_format                  = "AUTO"
  time_format                  = "AUTO"
  timestamp_format             = "AUTO"
  record_delimiter             = "\n"
  field_delimiter              = ","
  escape                       = "NONE"
  escape_unenclosed_field      = "\\"
}