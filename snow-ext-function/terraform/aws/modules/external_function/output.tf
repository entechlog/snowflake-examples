# -------------------------------------------------------------------------
# Outputs for AWS Lambda function details
# -------------------------------------------------------------------------
output "aws_lambda_function__arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.external_function_lambda.arn
}

output "aws_lambda_function__invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = aws_lambda_function.external_function_lambda.invoke_arn
}

output "aws_lambda_function__function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.external_function_lambda.function_name
}

output "aws_lambda_function__qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.external_function_lambda.qualified_arn
}

# -------------------------------------------------------------------------
# Outputs for API Gateway REST API details
# -------------------------------------------------------------------------
output "aws_api_gateway_rest_api__arn" {
  description = "The qualified ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.external_function_api.arn
}

output "aws_api_gateway_rest_api__execution_arn" {
  description = "The qualified execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.external_function_api.execution_arn
}

output "aws_api_gateway_rest_api__name" {
  description = "The name of the API Gateway"
  value       = aws_api_gateway_rest_api.external_function_api.name
}

# -------------------------------------------------------------------------
# Outputs for API Gateway deployment details
# -------------------------------------------------------------------------
output "aws_api_gateway_deployment__invoke_url" {
  description = "The invoke URL of the API Gateway endpoint"
  value       = local.aws_api_gateway_deployment_invoke_url
}

output "aws_api_gateway_deployment__url_of_proxy_and_resource" {
  description = "The URL of the API Gateway deployment proxy and resource"
  value       = local.aws_api_gateway_deployment_url_of_proxy_and_resource
}

# -------------------------------------------------------------------------
# Outputs for AWS caller identity details
# -------------------------------------------------------------------------
output "aws_caller_identity__account_id" {
  description = "The AWS account ID of the caller"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_identity__caller_arn" {
  description = "The ARN of the caller"
  value       = data.aws_caller_identity.current.arn
}

output "aws_caller_identity__caller_user_id" {
  description = "The user ID of the caller"
  value       = data.aws_caller_identity.current.user_id
}
