output "AWS_S3_BUCKET_NAME" {
  value = aws_s3_bucket.app.bucket
}

output "AWS_IAM_ROLE_ARN_MAGE" {
  value = aws_iam_role.mage_role.arn
}

output "AWS_IAM_USER_ARN_MAGE" {
  value = aws_iam_user.mage_user.arn
}

output "AWS_ACCESS_KEY_ID_MAGE" {
  value     = aws_iam_access_key.mage_user_key.id
  sensitive = false # You might want to set this to true in production settings
}

output "AWS_ACCESS_KEY_SECRET_MAGE" {
  value     = aws_iam_access_key.mage_user_key.secret
  sensitive = true # This ensures the actual value is not shown in the Terraform plan output
}
