# -------------------------------------------------------------------------
# External Function Demo Module
# -------------------------------------------------------------------------
module "external_function_demo" {
  source = "./modules/external_function"

  # Variables for Snowflake API integration
  snowflake_database_name        = "${upper(var.env_code)}_${upper(var.project_code)}_DEMO_DB"
  snowflake_schema_name          = "UTILS"
  snowflake_api_integration_name = snowflake_api_integration.external_function_api_integration.name

  aws_iam_role_arn                                        = var.aws_iam_role_arn
  external_function_api_gateway_url_of_proxy_and_resource = var.external_function_api_gateway_url_of_proxy_and_resource["demo"]

  snowflake_ext_function_name    = "demo"
  snowflake_function_grant_roles = ["SYSADMIN"]

  depends_on = [snowflake_schema.this, snowflake_api_integration.external_function_api_integration]
}

# -------------------------------------------------------------------------
# External Function Get Weather Module
# -------------------------------------------------------------------------
module "external_function_get_weather" {
  source = "./modules/external_function"

  # Variables for Snowflake API integration
  snowflake_database_name        = "${upper(var.env_code)}_${upper(var.project_code)}_DEMO_DB"
  snowflake_schema_name          = "UTILS"
  snowflake_api_integration_name = snowflake_api_integration.external_function_api_integration.name

  aws_iam_role_arn                                        = var.aws_iam_role_arn
  external_function_api_gateway_url_of_proxy_and_resource = var.external_function_api_gateway_url_of_proxy_and_resource["get_weather"]

  snowflake_ext_function_name    = "get_weather"
  snowflake_function_grant_roles = ["SYSADMIN"]

  depends_on = [snowflake_schema.this, snowflake_api_integration.external_function_api_integration]
}

# -------------------------------------------------------------------------
# External Function Get Weather Open Module
# -------------------------------------------------------------------------
module "external_function_get_weather_open" {
  source = "./modules/external_function"

  # Variables for Snowflake API integration
  snowflake_database_name        = "${upper(var.env_code)}_${upper(var.project_code)}_DEMO_DB"
  snowflake_schema_name          = "UTILS"
  snowflake_api_integration_name = snowflake_api_integration.external_function_api_integration.name

  aws_iam_role_arn                                        = var.aws_iam_role_arn
  external_function_api_gateway_url_of_proxy_and_resource = var.external_function_api_gateway_url_of_proxy_and_resource["get_weather_open"]

  snowflake_ext_function_name    = "get_weather_open"
  snowflake_function_grant_roles = ["SYSADMIN"]

  depends_on = [snowflake_schema.this, snowflake_api_integration.external_function_api_integration]
}

# -------------------------------------------------------------------------
# External Function Get IP Geolocation Module
# -------------------------------------------------------------------------
module "external_function_get_ip_geolocation" {
  source = "./modules/external_function"

  # Variables for Snowflake API integration
  snowflake_database_name        = "${upper(var.env_code)}_${upper(var.project_code)}_DEMO_DB"
  snowflake_schema_name          = "UTILS"
  snowflake_api_integration_name = snowflake_api_integration.external_function_api_integration.name

  aws_iam_role_arn                                        = var.aws_iam_role_arn
  external_function_api_gateway_url_of_proxy_and_resource = var.external_function_api_gateway_url_of_proxy_and_resource["get_ip_geolocation"]

  snowflake_ext_function_name    = "get_ip_geolocation"
  snowflake_function_grant_roles = ["SYSADMIN"]

  depends_on = [snowflake_schema.this, snowflake_api_integration.external_function_api_integration]
}