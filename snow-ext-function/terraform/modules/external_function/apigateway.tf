resource "aws_api_gateway_rest_api" "lambda_proxy" {
  name        = "${var.resource_name_prefix}-${lower(var.snowflake_ext_function_name)}-api"
  description = "Proxy AWS Gateway API to AWS Lambda"
}

resource "aws_api_gateway_resource" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
  parent_id   = aws_api_gateway_rest_api.lambda_proxy.root_resource_id
  path_part   = lower(var.snowflake_ext_function_name)
}

resource "aws_api_gateway_method" "lambda_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_proxy.id
  resource_id   = aws_api_gateway_resource.lambda_proxy.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
  resource_id = aws_api_gateway_method.lambda_proxy.resource_id
  http_method = aws_api_gateway_method.lambda_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.snow_ext_function.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
  stage_name  = lower(var.env_code)

  triggers = {
    build_number = timestamp()
  }

  depends_on = [aws_api_gateway_integration.lambda_proxy]
}

resource "aws_api_gateway_rest_api_policy" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
  policy      = data.aws_iam_policy_document.api_gateway_resource_policy.json
  depends_on  = [aws_api_gateway_deployment.lambda_proxy, aws_api_gateway_rest_api.lambda_proxy]
}