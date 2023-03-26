module "s3" {
  # module to create lambda resources in aws
  source         = "./modules/s3"
  s3_bucket_name = ["demo-snowflake"]
  use_env_code   = true
}

# demo-snowflake | start

# Enable Lambda to be invoked by S3
resource "aws_lambda_permission" "allow_s3" {

  for_each = toset(module.lambda_function.aws_lambda_function__function_name)

  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.demo_bucket_id[0]}"

  depends_on = [module.lambda_function, module.s3]
}

# Enable Lambda to be invoked by SNS

resource "aws_lambda_permission" "allow_sns" {

  for_each = toset(module.lambda_function.aws_lambda_function__function_name)

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = each.key
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.demo_bucket.arn

  depends_on = [module.lambda_function, module.s3]

}

# Enable Lambda trigger based on writes to S3
resource "aws_s3_bucket_notification" "demo_bucket" {

  bucket = local.demo_bucket_id[0]

  # dynamic "lambda_function" {
  #   for_each = toset(module.lambda_function.aws_lambda_function__arn)
  #   content {
  #     lambda_function_arn = lambda_function.key
  #     events              = ["s3:ObjectCreated:*"]
  #     filter_suffix       = ".pdf"
  #   }
  # }

  topic {
    topic_arn     = aws_sns_topic.demo_bucket.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".pdf"
  }

  depends_on = [aws_lambda_permission.allow_s3]

}

# Resource to add bucket policy to a bucket 
resource "aws_s3_bucket_policy" "s3_read_only_policy_document" {

  bucket = local.demo_bucket_id[0]
  policy = data.aws_iam_policy_document.s3_read_only_policy_document.json
}

# demo-snowflake | end