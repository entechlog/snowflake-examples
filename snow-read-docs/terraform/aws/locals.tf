locals {
  resource_name_prefix               = var.use_env_code == "true" ? "${lower(var.env_code)}-${lower(var.project_code)}" : "${lower(var.project_code)}"
  snowflake_storage_aws_iam_user_arn = coalesce(var.snowflake_storage_aws_iam_user_arn, data.aws_caller_identity.current.arn)
  tags                               = { Author = "Terraform" }

  demo_bucket_id = [
    for bucket_id in module.s3.aws_s3_bucket__id :
    bucket_id
    if split("${local.resource_name_prefix}-", bucket_id)[1] == "demo-snowflake"
  ]

  demo_bucket_arn = [
    for bucket_arn in module.s3.aws_s3_bucket__arn :
    bucket_arn
    if split("${local.resource_name_prefix}-", bucket_arn)[1] == "demo-snowflake"
  ]

}