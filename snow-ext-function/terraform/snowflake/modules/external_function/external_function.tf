resource "snowflake_external_function" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  name     = upper(each.key)
  database = upper(var.snowflake_database_name)
  schema   = upper(var.snowflake_schema_name)
  arg {
    name = "ARG1"
    type = "VARCHAR"
  }
  return_type               = "VARIANT"
  return_behavior           = "IMMUTABLE"
  max_batch_rows            = 10
  api_integration           = snowflake_api_integration.api_integration.name
  url_of_proxy_and_resource = lookup(var.aws_api_gateway_deployment__url_of_proxy_and_resource, each.key, "https://default")
}