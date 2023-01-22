// Output block starts here

output "database" {
  value = snowflake_database.database
}

output "schema" {
  value = snowflake_schema.schema
}