module "external_function_demo" {
  source = "./modules/external_function"

  # variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # function name
  snowflake_ext_function_name = "demo"
}

module "external_function_get_weather" {
  source = "./modules/external_function"

  # variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # function name
  snowflake_ext_function_name = "get_weather"
}


module "external_function_get_weather_open" {
  source = "./modules/external_function"

  # variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # env variables for lambda
  secrets = var.open_weather_secrets

  # snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # function name
  snowflake_ext_function_name = "get_weather_open"
}


module "external_function_get_ip_geolocation" {
  source = "./modules/external_function"

  # variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # env variables for lambda
  secrets = var.ipgeolocation_secrets

  # snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # function name
  snowflake_ext_function_name = "get_ip_geolocation"
}
