# -------------------------------------------------------------------------
# External Function Demo Module
# -------------------------------------------------------------------------
module "external_function_demo" {
  source = "./modules/external_function"

  # Variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # Snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # Function name
  snowflake_ext_function_name = "demo"
}

# -------------------------------------------------------------------------
# External Function Get Weather Module
# -------------------------------------------------------------------------
module "external_function_get_weather" {
  source = "./modules/external_function"

  # Variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # Snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # Function name
  snowflake_ext_function_name = "get_weather"
}

# -------------------------------------------------------------------------
# External Function Get Weather Open Module
# -------------------------------------------------------------------------
module "external_function_get_weather_open" {
  source = "./modules/external_function"

  # Variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # Environment variables for Lambda
  secrets = var.open_weather_secrets

  # Snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # Function name
  snowflake_ext_function_name = "get_weather_open"
}

# -------------------------------------------------------------------------
# External Function Get IP Geolocation Module
# -------------------------------------------------------------------------
module "external_function_get_ip_geolocation" {
  source = "./modules/external_function"

  # Variables for object naming and deployment
  env_code                             = var.env_code
  resource_name_prefix                 = local.resource_name_prefix
  snowflake_external_function_role_arn = aws_iam_role.external_function_snowflake_role.arn
  lambda_exec_role_arn                 = aws_iam_role.external_function_lambda_exec_role.arn
  lambda_exec_role_name                = aws_iam_role.external_function_snowflake_role.name
  cloudwatch_role_arn                  = aws_iam_role.external_function_cloudwatch_role.arn
  external_function_kms_key_id         = aws_kms_key.external_function_kms_lambda.key_id

  # Environment variables for Lambda
  secrets = var.ipgeolocation_secrets

  # Snowflake integration details
  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  # Function name
  snowflake_ext_function_name = "get_ip_geolocation"
}
