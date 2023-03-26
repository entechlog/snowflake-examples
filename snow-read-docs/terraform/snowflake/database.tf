//***************************************************************************//
// Create Snowflake database
//***************************************************************************//

resource "snowflake_database" "this" {
  name = var.snowflake_database_name
}

//***************************************************************************//
// Create Snowflake schema
//***************************************************************************//

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = var.snowflake_schema_name
}