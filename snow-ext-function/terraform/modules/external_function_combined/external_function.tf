resource "snowflake_external_function" "snow_ext_function" {

  for_each = toset(var.snowflake_ext_function_name)

  name     = upper(each.key)
  database = upper(var.snowflake_database_name)
  schema   = upper(var.snowflake_schema_name)
  arg {
    name = "arg1"
    type = "varchar"
  }
  return_type               = "variant"
  return_behavior           = "IMMUTABLE"
  api_integration           = snowflake_api_integration.api_integration.name
  url_of_proxy_and_resource = "${aws_api_gateway_deployment.lambda_proxy[each.key].invoke_url}/${lower(each.key)}"
}