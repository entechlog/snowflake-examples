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

//***************************************************************************//
// Create Snowflake resource monitor
//***************************************************************************//

# resource "snowflake_resource_monitor" "resource_monitor" {
#   name                       = snowflake_warehouse.warehouse.name
#   credit_quota               = var.resource_monitor_credit_quota
#   frequency                  = var.resource_monitor_frequency
#   start_timestamp            = var.resource_monitor_start_timestamp
#   notify_triggers            = var.resource_monitor_notify_triggers
#   suspend_triggers           = var.resource_monitor_suspend_triggers
#   suspend_immediate_triggers = var.resource_monitor_suspend_immediate_triggers
# }