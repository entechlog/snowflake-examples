module "external_function_demo" {
  source = "./modules/external_function"

  snowflake_account       = var.snowflake_account
  snowflake_region        = var.snowflake_region
  snowflake_user          = var.snowflake_user
  snowflake_password      = var.snowflake_password
  snowflake_role          = var.snowflake_role
  snowflake_database_name = var.snowflake_database_name
  snowflake_schema_name   = var.snowflake_schema_name

  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id
  snowflake_api_integration_name = snowflake_api_integration.api_integration.name

  resource_name_prefix            = local.resource_name_prefix
  iam_role_arn_snow_ext_function  = aws_iam_role.snow_ext_function.arn
  iam_role_name_snow_ext_function = aws_iam_role.snow_ext_function.name
  iam_role_arn_lambda_exec        = aws_iam_role.lambda_exec.arn

  snowflake_ext_function_name = "demo"
}

module "external_function_get_weather" {
  source = "./modules/external_function"

  snowflake_account       = var.snowflake_account
  snowflake_region        = var.snowflake_region
  snowflake_user          = var.snowflake_user
  snowflake_password      = var.snowflake_password
  snowflake_role          = var.snowflake_role
  snowflake_database_name = var.snowflake_database_name
  snowflake_schema_name   = var.snowflake_schema_name

  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id
  snowflake_api_integration_name = snowflake_api_integration.api_integration.name

  resource_name_prefix            = local.resource_name_prefix
  iam_role_arn_snow_ext_function  = aws_iam_role.snow_ext_function.arn
  iam_role_name_snow_ext_function = aws_iam_role.snow_ext_function.name
  iam_role_arn_lambda_exec        = aws_iam_role.lambda_exec.arn

  snowflake_ext_function_name = "get_weather"
}