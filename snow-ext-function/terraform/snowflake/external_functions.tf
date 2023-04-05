module "external_function" {
  source = "./modules/external_function"

  # variables for snowflake api integration
  snowflake_database_name        = "${upper(var.env_code)}_${upper(var.project_code)}_DEMO_DB"
  snowflake_schema_name          = "UTILS"
  snowflake_api_integration_name = "${upper(var.env_code)}_${upper(var.project_code)}_OW_API_AWS_INTG"

  aws_iam_role__arn                                     = var.aws_iam_role__arn
  aws_api_gateway_deployment__invoke_url                = var.aws_api_gateway_deployment__invoke_url
  aws_api_gateway_deployment__url_of_proxy_and_resource = var.aws_api_gateway_deployment__url_of_proxy_and_resource

  snowflake_ext_function_name     = ["demo", "get_weather", "get_weather_open"]
  snowflake_function_grant__roles = ["SYSADMIN"]

  depends_on = [snowflake_schema.this]
}