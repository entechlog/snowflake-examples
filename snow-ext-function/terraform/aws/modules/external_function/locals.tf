locals {
  api_aws_iam_user_arn = coalesce(var.snowflake_api_aws_iam_user_arn, data.aws_caller_identity.current.arn)

  # Local variables used for output
  aws_api_gateway_deployment__invoke_url = [for each in var.snowflake_ext_function_name :
    "${aws_api_gateway_deployment.lambda_proxy[each].invoke_url}"
  ]
  aws_api_gateway_deployment__url_of_proxy_and_resource = { for each in var.snowflake_ext_function_name :
    each => "${aws_api_gateway_deployment.lambda_proxy[each].invoke_url}/${lower(each)}"
  }

  tags = {
    Author = "Terraform"
  }
}
