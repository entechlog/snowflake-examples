resource "snowflake_external_function" "snow_ext_function" {
  name     = upper(var.snowflake_ext_function_name)
  database = upper(var.snowflake_database_name)
  schema   = upper(var.snowflake_schema_name)
  arg {
    name = "arg1"
    type = "varchar"
  }
  return_type               = "variant"
  return_behavior           = "IMMUTABLE"
  api_integration           = var.snowflake_api_integration_name
  url_of_proxy_and_resource = "${aws_api_gateway_deployment.lambda_proxy.invoke_url}/${lower(var.snowflake_ext_function_name)}"
}