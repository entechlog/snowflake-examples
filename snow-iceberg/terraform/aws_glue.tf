# AWS Glue Catalog Database for Iceberg tables
resource "aws_glue_catalog_database" "iceberg" {
  name        = var.glue_database_name
  description = "Glue database for Iceberg tables created by PyIceberg generator"

  tags = local.common_tags
}
