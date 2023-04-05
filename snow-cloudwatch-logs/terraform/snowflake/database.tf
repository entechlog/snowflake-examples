//***************************************************************************//
// Create Snowflake database
//***************************************************************************//

resource "snowflake_database" "this" {
  name    = "${upper(local.resource_name_prefix)}_DEMO_DB"
  comment = "Database to store the demo data"
}

//***************************************************************************//
// Create Snowflake schema
//***************************************************************************//

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "UTILS"
}