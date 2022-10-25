# AWS | Lambda 
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = join("", aws_lambda_function.snow_ext_function.*.arn)
}

output "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = join("", aws_lambda_function.snow_ext_function.*.invoke_arn)
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = join("", aws_lambda_function.snow_ext_function.*.function_name)
}

output "lambda_function_qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = join("", aws_lambda_function.snow_ext_function.*.qualified_arn)
}

# AWS | API Gateway

output "api_gateway_arn" {
  description = "The qualified ARN of the API Gateway"
  value       = join("", aws_api_gateway_rest_api.lambda_proxy.*.arn)
}

output "api_gateway_execution_arn" {
  description = "The qualified execution ARN of the API Gateway"
  value       = join("", aws_api_gateway_rest_api.lambda_proxy.*.execution_arn)
}

output "api_gateway_name" {
  description = "The name of the API Gateway"
  value       = join("", aws_api_gateway_rest_api.lambda_proxy.*.name)
}

output "aws_api_gateway_deployment_invoke_url" {
  description = "The invoke url of the API Gateway endpoint"
  value       = join("", aws_api_gateway_deployment.lambda_proxy.*.invoke_url)
}

# AWS account details

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}