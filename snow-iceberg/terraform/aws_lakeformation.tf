# Lake Formation Data Lake Settings
# Adds current terraform user and root as admins
resource "aws_lakeformation_data_lake_settings" "settings" {
  admins = [
    data.aws_caller_identity.current.arn,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

# Lake Formation permissions for each Glue database in iceberg_tables
# Only grant after ingestion methods have created the databases (controlled by create_iceberg_tables flag)
resource "aws_lakeformation_permissions" "database" {
  for_each = var.create_iceberg_tables ? var.iceberg_tables : {}

  principal   = aws_iam_role.external_volume_role.arn
  permissions = ["DESCRIBE"]

  database {
    name = each.key
  }

  depends_on = [aws_lakeformation_data_lake_settings.settings]
}

# Lake Formation permissions for all tables in each database
# Only grant after tables exist (controlled by create_iceberg_tables flag)
resource "aws_lakeformation_permissions" "tables" {
  for_each = var.create_iceberg_tables ? var.iceberg_tables : {}

  principal   = aws_iam_role.external_volume_role.arn
  permissions = ["SELECT", "DESCRIBE"]

  table {
    database_name = each.key
    wildcard      = true
  }

  depends_on = [aws_lakeformation_permissions.database]
}
