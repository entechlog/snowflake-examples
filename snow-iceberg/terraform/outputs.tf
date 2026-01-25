# Iceberg catalog outputs
output "iceberg_catalog_integration_name" {
  description = "Snowflake Iceberg catalog integration name"
  value       = local.iceberg_catalog_integration_name
}

# External Volumes outputs
output "external_volume_bucket_name" {
  description = "External volume S3 bucket name"
  value       = module.external_volume_bucket.aws_s3_bucket__name[0]
}

output "external_volume_iam_role_arn" {
  description = "IAM role ARN for External Volume access"
  value       = aws_iam_role.external_volume_role.arn
}

output "external_volume_name" {
  description = "Snowflake external volume name"
  value       = snowflake_external_volume.raw_data_volume.name
}

output "storage_integration_name" {
  description = "Snowflake storage integration name"
  value       = snowflake_storage_integration.raw_data_s3_integration.name
}

# Database and schema outputs
output "database_name" {
  description = "Snowflake database name"
  value       = local.database_name
}

# Iceberg generator IAM outputs
output "iceberg_generator_access_key_id" {
  description = "Access key ID for Iceberg data generator (use with AWS_ACCESS_KEY_ID)"
  value       = aws_iam_access_key.iceberg_generator_key.id
}

output "iceberg_generator_secret_access_key" {
  description = "Secret access key for Iceberg data generator (use with AWS_SECRET_ACCESS_KEY)"
  value       = aws_iam_access_key.iceberg_generator_key.secret
  sensitive   = true
}

output "iceberg_warehouse_path" {
  description = "S3 warehouse path for Iceberg tables"
  value       = "s3://${module.external_volume_bucket.aws_s3_bucket__name[0]}/${var.s3_warehouse_prefix}"
}

output "glue_database_name" {
  description = "Glue database name for Iceberg catalog"
  value       = var.glue_database_name
}

output "manual_steps_iam_trust" {
  description = "Manual steps for IAM trust configuration"
  value = [
    "1. Run: DESC EXTERNAL VOLUME ${local.external_volume_name};",
    "2. Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID values",
    "3. Update terraform.tfvars with external_volume_snowflake_iam_user_arn and external_volume_aws_external_id",
    "4. Run: DESC STORAGE INTEGRATION ${local.storage_integration_name};",
    "5. Copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID values",
    "6. Update terraform.tfvars with storage_integration_snowflake_iam_user_arn and storage_integration_aws_external_id",
    "7. Run: DESC CATALOG INTEGRATION ${local.iceberg_catalog_integration_name};",
    "8. Copy GLUE_AWS_IAM_USER_ARN and GLUE_AWS_EXTERNAL_ID values",
    "9. Update terraform.tfvars with catalog_integration_snowflake_iam_user_arn and catalog_integration_aws_external_id",
    "10. Run terraform apply to update IAM trust relationships",
    "11. Verify: SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('${local.external_volume_name}');"
  ]
}