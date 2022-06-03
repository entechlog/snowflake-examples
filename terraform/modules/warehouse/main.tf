terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.33.1"
    }
  }
}

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

resource "snowflake_warehouse_grant" "warehouse_grant" {
  for_each = var.warehouse_grant_roles

  warehouse_name    = snowflake_warehouse.warehouse.name
  privilege         = each.key
  roles             = each.value
  with_grant_option = var.warehouse_grant_with_grant_option
}