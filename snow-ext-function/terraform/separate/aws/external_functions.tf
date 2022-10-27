module "external_function" {
  # combined module with code to create resources in aws and snowflake
  source = "../../modules/external_function_aws"

  snowflake_api_aws_iam_user_arn = var.snowflake_api_aws_iam_user_arn
  snowflake_api_aws_external_id  = var.snowflake_api_aws_external_id

  snowflake_ext_function_name = ["demo", "get_weather"]
}
