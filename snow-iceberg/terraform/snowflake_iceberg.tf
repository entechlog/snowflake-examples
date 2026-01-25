# Wait for AWS resources (IAM role, Glue database, and Lake Formation permissions)
resource "time_sleep" "wait_for_aws" {
  create_duration = var.resource_creation_wait_time

  depends_on = [
    aws_glue_catalog_database.iceberg,
    aws_iam_role.external_volume_role,
    aws_iam_user_policy_attachment.iceberg_generator_attachment,
    aws_lakeformation_permissions.database
  ]
}

# Snowflake Iceberg catalog integration pointing to AWS Glue Catalog
resource "snowflake_execute" "iceberg_catalog_integration" {
  execute = <<-EOF
    CREATE OR REPLACE CATALOG INTEGRATION ${local.iceberg_catalog_integration_name}
      CATALOG_SOURCE = GLUE
      TABLE_FORMAT = ICEBERG
      CATALOG_NAMESPACE = '${var.glue_database_name}'
      GLUE_AWS_ROLE_ARN = '${aws_iam_role.external_volume_role.arn}'
      GLUE_CATALOG_ID = '${data.aws_caller_identity.current.account_id}'
      GLUE_REGION = '${var.aws_region}'
      ENABLED = TRUE;
  EOF

  revert = "DROP CATALOG INTEGRATION IF EXISTS ${local.iceberg_catalog_integration_name};"

  depends_on = [
    time_sleep.wait_for_aws,
    aws_iam_role.external_volume_role
  ]
}

# Wait for catalog integration to be ready
resource "time_sleep" "wait_for_catalog_integration" {
  create_duration = var.resource_creation_wait_time

  depends_on = [snowflake_execute.iceberg_catalog_integration]
}

# Create Snowflake external Iceberg tables
# Only create if create_iceberg_tables is true (after PyIceberg generator has created tables in Glue)
#
# For each source system (e.g., 'faker', 'hubspot', 'billing_db'):
#   - Creates Snowflake schema named after source (e.g., FAKER, HUBSPOT, BILLING_DB)
#   - Creates Iceberg tables within that schema
#   - Example: database.FAKER.CUSTOMERS, database.HUBSPOT.CONTACTS, database.BILLING_DB.INVOICES
resource "snowflake_execute" "iceberg_tables" {
  for_each = var.create_iceberg_tables ? {
    for item in flatten([
      for source, tables in var.iceberg_tables : [
        for table in tables : {
          key    = "${source}_${table}"
          source = source
          table  = table
        }
      ]
    ]) : item.key => item
  } : {}

  execute = <<-EOF
    CREATE OR REPLACE ICEBERG TABLE ${local.database_name}.${upper(each.value.source)}.${upper(each.value.table)}
      EXTERNAL_VOLUME = '${snowflake_external_volume.raw_data_volume.name}'
      CATALOG = '${local.iceberg_catalog_integration_name}'
      CATALOG_TABLE_NAME = '${each.value.table}'
      CATALOG_NAMESPACE = '${each.value.source}'
      AUTO_REFRESH = TRUE;
  EOF

  revert = "DROP TABLE IF EXISTS ${local.database_name}.${upper(each.value.source)}.${upper(each.value.table)};"

  depends_on = [
    time_sleep.wait_for_catalog_integration,
    snowflake_external_volume.raw_data_volume
  ]
}
