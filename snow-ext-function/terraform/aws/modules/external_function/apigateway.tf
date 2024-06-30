resource "aws_api_gateway_rest_api" "external_function_api" {
  name        = replace("${var.resource_name_prefix}-${lower(var.snowflake_ext_function_name)}-api", "_", "-")
  description = "Proxy AWS Gateway API to AWS Lambda"
}

resource "aws_api_gateway_resource" "external_function_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.external_function_api.id
  parent_id   = aws_api_gateway_rest_api.external_function_api.root_resource_id
  path_part   = lower(var.snowflake_ext_function_name)
}

resource "aws_api_gateway_method" "external_function_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.external_function_api.id
  resource_id   = aws_api_gateway_resource.external_function_api_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "external_function_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.external_function_api.id
  resource_id = aws_api_gateway_method.external_function_api_method.resource_id
  http_method = aws_api_gateway_method.external_function_api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.external_function_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "external_function_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.external_function_api.id
  stage_name  = lower(var.env_code)

  triggers = {
    build_number = "${md5(var.snowflake_api_aws_external_id)}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.external_function_api_integration]
}

resource "aws_api_gateway_rest_api_policy" "external_function_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.external_function_api.id
  policy      = data.aws_iam_policy_document.external_function_api_gateway_resource_policy.json
  depends_on  = [aws_api_gateway_deployment.external_function_api_deployment, aws_api_gateway_rest_api.external_function_api]
}

resource "aws_api_gateway_account" "external_function_api_account" {
  cloudwatch_role_arn = var.cloudwatch_role_arn
}

resource "aws_api_gateway_method_settings" "external_function_api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.external_function_api.id
  stage_name  = lower(var.env_code)
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = false
    logging_level      = "ERROR"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 1000
    throttling_burst_limit = 500
  }

  depends_on = [aws_api_gateway_deployment.external_function_api_deployment, aws_api_gateway_rest_api.external_function_api, aws_cloudwatch_log_group.external_function_api_gateway_log_group]
}