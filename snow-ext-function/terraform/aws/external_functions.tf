module "external_function" {
  source = "./modules/external_function"

  # variables for object naming and deployment
  env_code             = var.env_code
  resource_name_prefix = local.resource_name_prefix

  # env variables for lambda
  open_weather_api_key = var.TF_VAR_open_weather_api_key

  # snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # function name
  snowflake_ext_function_name = ["demo", "get_weather", "get_weather_open"]
}
