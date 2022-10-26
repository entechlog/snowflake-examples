output "aws_lambda_function__arn" {
  value = module.external_function.aws_lambda_function__arn
}

output "aws_lambda_function__invoke_arn" {
  value = module.external_function.aws_lambda_function__invoke_arn
}

output "aws_lambda_function__function_name" {
  value = module.external_function.aws_lambda_function__function_name
}

output "aws_api_gateway_rest_api__execution_arn" {
  value = module.external_function.aws_api_gateway_rest_api__execution_arn
}

output "aws_api_gateway_deployment__invoke_url" {
  value = module.external_function.aws_api_gateway_deployment__invoke_url
}

output "aws_iam_role__arn" {
  value = module.external_function.aws_iam_role__arn
}