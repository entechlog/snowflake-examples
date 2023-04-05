resource "aws_api_gateway_rest_api" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  name        = replace("${var.resource_name_prefix}-${lower(each.key)}-api", "_", "-")
  description = "Proxy AWS Gateway API to AWS Lambda"
}

resource "aws_api_gateway_resource" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id = aws_api_gateway_rest_api.lambda_proxy[each.key].id
  parent_id   = aws_api_gateway_rest_api.lambda_proxy[each.key].root_resource_id
  path_part   = lower(each.key)
}

resource "aws_api_gateway_method" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id   = aws_api_gateway_rest_api.lambda_proxy[each.key].id
  resource_id   = aws_api_gateway_resource.lambda_proxy[each.key].id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id = aws_api_gateway_rest_api.lambda_proxy[each.key].id
  resource_id = aws_api_gateway_method.lambda_proxy[each.key].resource_id
  http_method = aws_api_gateway_method.lambda_proxy[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.snow_ext_function[each.key].invoke_arn
}

resource "aws_api_gateway_deployment" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id = aws_api_gateway_rest_api.lambda_proxy[each.key].id
  stage_name  = lower(var.env_code)

  triggers = {
    build_number = "${md5(var.snowflake_api_aws_external_id)}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.lambda_proxy]
}

resource "aws_api_gateway_rest_api_policy" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id = aws_api_gateway_rest_api.lambda_proxy[each.key].id
  policy      = data.aws_iam_policy_document.api_gateway_resource_policy[each.key].json
  depends_on  = [aws_api_gateway_deployment.lambda_proxy, aws_api_gateway_rest_api.lambda_proxy]
}

resource "aws_api_gateway_account" "lambda_proxy" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_api_gateway_method_settings" "lambda_proxy" {

  for_each = toset(var.snowflake_ext_function_name)

  rest_api_id = aws_api_gateway_rest_api.lambda_proxy[each.key].id
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

  depends_on = [aws_api_gateway_deployment.lambda_proxy, aws_api_gateway_rest_api.lambda_proxy, aws_cloudwatch_log_group.snow_ext_function_api_gateway]
}