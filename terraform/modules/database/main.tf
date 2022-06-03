terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.33.1"
    }
  }
}

resource "snowflake_database" "database" {
  name    = var.db_name
  comment = var.db_comment
}

resource "snowflake_database_grant" "database_grant" {

  for_each = var.db_grant_roles

  database_name     = snowflake_database.database.name
  privilege         = each.key
  roles             = each.value
  with_grant_option = false
}

resource "snowflake_schema" "schema" {

  for_each = toset(var.schemas)

  database = snowflake_database.database.name
  name     = each.key
}

output "database" {
  value = snowflake_database.database
}

output "schema" {
  value = snowflake_schema.schema
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