terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.35.0"
    }
  }
}

resource "snowflake_schema" "schema" {
  database = var.database_name
  name     = var.schema_name
}

resource "snowflake_schema_grant" "schema_grant" {

  for_each = var.schema_grant

  database_name     = snowflake_database.database.name
  schema_name       = split(" ", each.key)[0]
  privilege         = join(" ", slice(split(" ", each.key), 1, length(split(" ", each.key))))
  roles             = each.value.roles
  with_grant_option = false
  depends_on        = [snowflake_schema.schema]
}

resource "snowflake_table_grant" "table_grant" {

  for_each      = var.table_grant
  database_name = snowflake_database.database.name
  schema_name   = snowflake_schema.schema.name

  privilege = each.key
  roles     = each.value.roles

  on_future         = true
  with_grant_option = false
}


output "schema" {
  value = snowflake_schema.schema
}