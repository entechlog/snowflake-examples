# AWS | Lambda 
output "aws_lambda_function__arn" {
  description = "The ARN of the Lambda function"
  value       = values(aws_lambda_function.lambda_function).*.arn
}

output "aws_lambda_function__invoke_arn" {
  description = "The Invoke ARN of the Lambda function"
  value       = values(aws_lambda_function.lambda_function).*.invoke_arn
}

output "aws_lambda_function__function_name" {
  description = "The name of the Lambda function"
  value       = values(aws_lambda_function.lambda_function).*.function_name
}

output "aws_lambda_function__qualified_arn" {
  description = "The qualified ARN of the Lambda function"
  value       = values(aws_lambda_function.lambda_function).*.qualified_arn
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