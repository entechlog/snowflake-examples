//***************************************************************************//
// Create Snowflake db grants
//***************************************************************************//

resource "snowflake_database_grant" "database_grant" {

  for_each = var.db_grant_roles

  database_name     = var.db_name
  privilege         = each.key
  roles             = each.value
  with_grant_option = false
}