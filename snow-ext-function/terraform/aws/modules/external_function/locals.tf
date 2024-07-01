locals {
  # -------------------------------------------------------------------------
  # Local variable for API Gateway deployment invoke URL
  # -------------------------------------------------------------------------
  aws_api_gateway_deployment_invoke_url = aws_api_gateway_deployment.external_function_api_deployment.invoke_url

  # -------------------------------------------------------------------------
  # Local variable for URL of the API Gateway deployment proxy and resource
  # -------------------------------------------------------------------------
  aws_api_gateway_deployment_url_of_proxy_and_resource = "${aws_api_gateway_deployment.external_function_api_deployment.invoke_url}/${lower(var.snowflake_ext_function_name)}"
}
