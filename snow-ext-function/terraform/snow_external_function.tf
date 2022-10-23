resource "snowflake_external_function" "snow_ext_function" {
  name     = lower(var.snowflake_ext_function_name)
  database = var.snowflake_database_name
  schema   = var.snowflake_schema_name
  arg {
    name = "arg1"
    type = "varchar"
  }
  arg {
    name = "arg2"
    type = "varchar"
  }
  return_type               = "variant"
  return_behavior           = "IMMUTABLE"
  api_integration           = snowflake_api_integration.api_integration.name
  url_of_proxy_and_resource = "${aws_api_gateway_deployment.lambda_proxy.invoke_url}/${lower(var.snowflake_ext_function_name)}"
}