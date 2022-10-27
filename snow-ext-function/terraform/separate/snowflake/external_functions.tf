module "external_function" {
  # combined module with code to create resources in aws and snowflake
  source = "../../modules/external_function_snowflake"

  snowflake_account              = var.snowflake_account
  snowflake_region               = var.snowflake_region
  snowflake_user                 = var.snowflake_user
  snowflake_password             = var.snowflake_password
  snowflake_role                 = var.snowflake_role
  snowflake_database_name        = var.snowflake_database_name
  snowflake_schema_name          = var.snowflake_schema_name
  snowflake_api_integration_name = var.snowflake_api_integration_name

  aws_iam_role__arn                                     = var.aws_iam_role__arn
  aws_api_gateway_deployment__invoke_url                = var.aws_api_gateway_deployment__invoke_url
  aws_api_gateway_deployment__url_of_proxy_and_resource = var.aws_api_gateway_deployment__url_of_proxy_and_resource

  snowflake_ext_function_name = ["demo", "get_weather"]
}
