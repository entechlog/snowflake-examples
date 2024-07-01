# -------------------------------------------------------------------------
# Snowflake Function Grant
# -------------------------------------------------------------------------
resource "snowflake_function_grant" "external_function_grant" {
  database_name = upper(var.snowflake_database_name)
  schema_name   = upper(var.snowflake_schema_name)

  privilege         = "USAGE"
  roles             = var.snowflake_function_grant_roles
  on_future         = true
  with_grant_option = false
}
