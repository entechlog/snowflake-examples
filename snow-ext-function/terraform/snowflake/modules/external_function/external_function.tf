# -------------------------------------------------------------------------
# Snowflake External Function
# -------------------------------------------------------------------------
resource "snowflake_external_function" "external_function" {
  name     = upper(var.snowflake_ext_function_name)
  database = upper(var.snowflake_database_name)
  schema   = upper(var.snowflake_schema_name)

  arg {
    name = "ARG1"
    type = "VARCHAR"
  }

  return_type               = "VARIANT"
  return_behavior           = "IMMUTABLE"
  max_batch_rows            = 10
  api_integration           = var.snowflake_api_integration_name
  url_of_proxy_and_resource = var.external_function_api_gateway_url_of_proxy_and_resource
}
