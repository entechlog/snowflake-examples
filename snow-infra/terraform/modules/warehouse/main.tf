//***************************************************************************//
// Create Snowflake warehouse
//***************************************************************************//

resource "snowflake_warehouse" "warehouse" {
  name                = var.warehouse_name
  comment             = var.warehouse_comment
  warehouse_size      = var.warehouse_size
  auto_resume         = var.warehouse_auto_resume
  auto_suspend        = var.warehouse_auto_suspend
  initially_suspended = var.warehouse_initially_suspended
  max_cluster_count   = var.warehouse_max_cluster_count
  min_cluster_count   = var.warehouse_min_cluster_count
  scaling_policy      = "ECONOMY" //Should be in CAPS
}

//***************************************************************************//
// Create Snowflake warehouse grants
//***************************************************************************//
resource "snowflake_grant_ownership" "ownership_warehouse_grant" {
  for_each = { for k, v in var.warehouse_grant : k => v if v.privileges[0] == "OWNERSHIP" }

  on {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse.name
  }

  account_role_name = each.value.role_name
  depends_on        = [snowflake_warehouse.warehouse]
}

resource "snowflake_grant_privileges_to_account_role" "warehouse_grant" {
  for_each = { for k, v in var.warehouse_grant : k => v if v.privileges[0] != "OWNERSHIP" }

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.warehouse.name
  }

  privileges        = each.value.privileges
  account_role_name = each.value.role_name

  depends_on = [snowflake_warehouse.warehouse, snowflake_grant_ownership.ownership_warehouse_grant]
}
