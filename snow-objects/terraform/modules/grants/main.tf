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

//***************************************************************************//
// Create Snowflake schema grants
//***************************************************************************//

resource "snowflake_grant_privileges_to_role" "ownership_schema_grant" {
  for_each = { for k, v in var.schema_grant : k => v if v.privileges[0] == "OWNERSHIP" }

  on_schema {
    schema_name = "${var.db_name}.${split(" ", each.key)[0]}"
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = true
  depends_on        = [snowflake_database_grant.database_grant]
}

resource "snowflake_grant_privileges_to_role" "schema_grant" {
  for_each = { for k, v in var.schema_grant : k => v if v.privileges[0] != "OWNERSHIP" }

  on_schema {
    schema_name = "${var.db_name}.${split(" ", each.key)[0]}"
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_database_grant.database_grant, snowflake_grant_privileges_to_role.ownership_schema_grant]
}

//***************************************************************************//
// Create Snowflake table grants
//***************************************************************************//

resource "snowflake_grant_privileges_to_role" "table_grant_existing" {

  for_each = var.table_grant

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant]
}

resource "snowflake_grant_privileges_to_role" "table_grant_future" {

  for_each = var.table_grant

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant, snowflake_grant_privileges_to_role.table_grant_existing]
}

//***************************************************************************//
// Create Snowflake stage grants
//***************************************************************************//

resource "snowflake_grant_privileges_to_role" "stage_grant_existing" {

  for_each = var.stage_grant

  on_schema_object {
    all {
      object_type_plural = "STAGES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant]
}

resource "snowflake_grant_privileges_to_role" "stage_grant_future" {

  for_each = var.stage_grant

  on_schema_object {
    future {
      object_type_plural = "STAGES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant, snowflake_grant_privileges_to_role.stage_grant_existing]
}

//***************************************************************************//
// Create Snowflake pipe grants
//***************************************************************************//

resource "snowflake_grant_privileges_to_role" "pipe_grant_existing" {

  for_each = var.pipe_grant

  on_schema_object {
    all {
      object_type_plural = "PIPES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant]
}

resource "snowflake_grant_privileges_to_role" "pipe_grant_future" {

  for_each = var.pipe_grant

  on_schema_object {
    future {
      object_type_plural = "PIPES"
      in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant, snowflake_grant_privileges_to_role.pipe_grant_existing]
}