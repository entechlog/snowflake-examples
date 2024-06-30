locals {
  # Local variables used for output
  aws_api_gateway_deployment_invoke_url = aws_api_gateway_deployment.external_function_api_deployment.invoke_url

  aws_api_gateway_deployment_url_of_proxy_and_resource = "${aws_api_gateway_deployment.external_function_api_deployment.invoke_url}/${lower(var.snowflake_ext_function_name)}"

}