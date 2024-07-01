# -------------------------------------------------------------------------
# Output for the ARN of the Snowflake external function IAM role
# -------------------------------------------------------------------------
output "aws_iam_role_arn" {
  value = aws_iam_role.external_function_snowflake_role.arn
}

# -------------------------------------------------------------------------
# Output for API Gateway invoke URLs
# -------------------------------------------------------------------------
output "external_function_api_gateway_urls" {
  description = "API Gateway invoke URLs"
  value = {
    demo               = module.external_function_demo.aws_api_gateway_deployment__invoke_url
    get_weather        = module.external_function_get_weather.aws_api_gateway_deployment__invoke_url
    get_weather_open   = module.external_function_get_weather_open.aws_api_gateway_deployment__invoke_url
    get_ip_geolocation = module.external_function_get_ip_geolocation.aws_api_gateway_deployment__invoke_url
  }
}

# -------------------------------------------------------------------------
# Output for API Gateway URLs with proxy and resource
# -------------------------------------------------------------------------
output "external_function_api_gateway_url_of_proxy_and_resource" {
  description = "API Gateway URLs with proxy and resource"
  value = {
    demo               = module.external_function_demo.aws_api_gateway_deployment__url_of_proxy_and_resource
    get_weather        = module.external_function_get_weather.aws_api_gateway_deployment__url_of_proxy_and_resource
    get_weather_open   = module.external_function_get_weather_open.aws_api_gateway_deployment__url_of_proxy_and_resource
    get_ip_geolocation = module.external_function_get_ip_geolocation.aws_api_gateway_deployment__url_of_proxy_and_resource
  }
}

# Uncomment the following outputs if needed

# -------------------------------------------------------------------------
# Output for ARNs of the Lambda functions
# -------------------------------------------------------------------------
# output "external_function_arns" {
#   description = "ARNs of the Lambda functions"
#   value = {
#     demo              = module.external_function_demo.aws_lambda_function__arn
#     get_weather       = module.external_function_get_weather.aws_lambda_function__arn
#     get_weather_open  = module.external_function_get_weather_open.aws_lambda_function__arn
#     get_ip_geolocation = module.external_function_get_ip_geolocation.aws_lambda_function__arn
#   }
# }

# -------------------------------------------------------------------------
# Output for Invoke ARNs of the Lambda functions
# -------------------------------------------------------------------------
# output "external_function_invoke_arns" {
#   description = "Invoke ARNs of the Lambda functions"
#   value = {
#     demo              = module.external_function_demo.aws_lambda_function__invoke_arn
#     get_weather       = module.external_function_get_weather.aws_lambda_function__invoke_arn
#     get_weather_open  = module.external_function_get_weather_open.aws_lambda_function__invoke_arn
#     get_ip_geolocation = module.external_function_get_ip_geolocation.aws_lambda_function__invoke_arn
#   }
# }
