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
  depends_on        = [snowflake_database.database]
}

resource "snowflake_schema" "schema" {

  for_each = toset(var.schemas)

  database   = snowflake_database.database.name
  name       = each.key
  depends_on = [snowflake_database_grant.database_grant]
}

resource "snowflake_grant_privileges_to_role" "ownership_schema_grant" {
  for_each = { for k, v in var.schema_grant : k => v if v.privileges[0] == "OWNERSHIP" }

  on_schema {
    schema_name = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = true
  depends_on        = [snowflake_schema.schema]
}

resource "snowflake_grant_privileges_to_role" "schema_grant" {
  for_each = { for k, v in var.schema_grant : k => v if v.privileges[0] != "OWNERSHIP" }

  on_schema {
    schema_name = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema, snowflake_grant_privileges_to_role.ownership_schema_grant]
}

resource "snowflake_grant_privileges_to_role" "table_grant_existing" {

  for_each = var.table_grant

  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema]
}

resource "snowflake_grant_privileges_to_role" "table_grant_future" {

  for_each = var.table_grant

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema, snowflake_grant_privileges_to_role.table_grant_existing]
}

resource "snowflake_grant_privileges_to_role" "view_grant_existing" {

  for_each = var.view_grant

  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema]
}

resource "snowflake_grant_privileges_to_role" "view_grant_future" {

  for_each = var.view_grant

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema, snowflake_grant_privileges_to_role.view_grant_existing]
}

resource "snowflake_grant_privileges_to_role" "materialized_view_grant_existing" {

  for_each = var.view_grant

  on_schema_object {
    all {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema]
}

resource "snowflake_grant_privileges_to_role" "materialized_view_grant_future" {

  for_each = var.view_grant

  on_schema_object {
    future {
      object_type_plural = "MATERIALIZED VIEWS"
      in_schema          = "${snowflake_database.database.name}.${split(" ", each.key)[0]}"
    }
  }

  privileges        = each.value.privileges
  role_name         = each.value.role_name
  with_grant_option = false
  depends_on        = [snowflake_schema.schema, snowflake_grant_privileges_to_role.materialized_view_grant_existing]
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

// Commenting the existing pipe grant block because of below error
// Error: error granting privileges to account role: 003111 (0A000): SQL compilation error:
// Bulk grant on objects of type PIPE to ROLE is restricted.

# resource "snowflake_grant_privileges_to_role" "pipe_grant_existing" {

#   for_each = var.pipe_grant

#   on_schema_object {
#     all {
#       object_type_plural = "PIPES"
#       in_schema          = "${var.db_name}.${split(" ", each.key)[0]}"
#     }
#   }

#   privileges        = each.value.privileges
#   role_name         = each.value.role_name
#   with_grant_option = false
#   depends_on        = [snowflake_grant_privileges_to_role.schema_grant]
# }

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
  depends_on        = [snowflake_grant_privileges_to_role.schema_grant]
}