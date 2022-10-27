# AWS | Lambda 
output "aws_lambda_function__arn" {
  description = "The ARN of the Lambda function"
  value       = join(", ", values(aws_lambda_function.snow_ext_function).*.arn)
}

output "aws_lambda_function__invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = join(", ", values(aws_lambda_function.snow_ext_function).*.invoke_arn)
}

output "aws_lambda_function__function_name" {
  description = "The name of the Lambda function"
  value       = join(", ", values(aws_lambda_function.snow_ext_function).*.function_name)
}

output "aws_lambda_function__qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = join(", ", values(aws_lambda_function.snow_ext_function).*.qualified_arn)
}

# AWS | API Gateway

output "aws_api_gateway_rest_api__arn" {
  description = "The qualified ARN of the API Gateway"
  value       = join(", ", values(aws_api_gateway_rest_api.lambda_proxy).*.arn)
}

output "aws_api_gateway_rest_api__execution_arn" {
  description = "The qualified execution ARN of the API Gateway"
  value       = join(", ", values(aws_api_gateway_rest_api.lambda_proxy).*.execution_arn)
}

output "aws_api_gateway_rest_api__name" {
  description = "The name of the API Gateway"
  value       = join(", ", values(aws_api_gateway_rest_api.lambda_proxy).*.name)
}

output "aws_api_gateway_deployment__invoke_url" {
  description = "The invoke url of the API Gateway endpoint"
  value       = join(", ", values(aws_api_gateway_deployment.lambda_proxy).*.invoke_url)
}

output "aws_api_gateway_deployment__url_of_proxy_and_resource" {
  value = local.aws_api_gateway_deployment__url_of_proxy_and_resource
}

# AWS account details

output "aws_caller_identity__account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_identity__caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_caller_identity__caller_user_id" {
  value = data.aws_caller_identity.current.user_id
}

# AWS | IAM

# output "aws_iam_role__name_snowflake" {
#   description = "IAM role name used by Snowflake external function to make API Gateway/Lambda call"
#   value       = join(", ", aws_iam_role.snow_ext_function.*.name)
# }

output "aws_iam_role__arn" {
  description = "IAM role arn used by Snowflake external function to make API Gateway/Lambda call"
  value       = join(", ", aws_iam_role.snow_ext_function.*.arn)
}