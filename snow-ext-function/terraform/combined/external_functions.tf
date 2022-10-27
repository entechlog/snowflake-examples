module "external_function" {
  # combined module with code to create resources in aws and snowflake
  source = "../modules/external_function_combined"

  snowflake_account       = var.snowflake_account
  snowflake_region        = var.snowflake_region
  snowflake_user          = var.snowflake_user
  snowflake_password      = var.snowflake_password
  snowflake_role          = var.snowflake_role
  snowflake_database_name = var.snowflake_database_name
  snowflake_schema_name   = var.snowflake_schema_name

  snowflake_api_integration_name = var.snowflake_api_integration_name
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  snowflake_ext_function_name = ["demo", "get_weather"]
}
